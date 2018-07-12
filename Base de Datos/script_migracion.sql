-- roles
create table roles (
  id_rol int PRIMARY KEY NOT NULL IDENTITY(1,1),
  nombre nvarchar(255),
  estado bit default 1
)

set identity_insert roles on;
insert into roles (id_rol, nombre)
values
  (1, 'Administrador'),
  (2, 'Recepcionista'),
  (3, 'Guest'),
  (4, 'Administrador General')
set identity_insert roles off;

-- funcionalidades
create table funcionalidades (
  id_funcionalidad int PRIMARY KEY NOT NULL IDENTITY(1,1),
  descripcion nvarchar(255)
)

set identity_insert funcionalidades on;
insert into funcionalidades (id_funcionalidad, descripcion)
values
  (1, 'ABM Rol'),
  (2, 'ABM Usuario'),
  (3, 'ABM Cliente'),
  (4, 'ABM Hotel'),
  (5, 'ABM Habitacion'),
  (6, 'ABM Regimen de Estadia'),
  (7, 'Generar o Modificar Reserva'),
  (8, 'Cancelar Reserva'),
  (9, 'Registrar Estadia'),
  (10, 'Registrar Consumibles'),
  (11, 'Facturar Estadia'),
  (12, 'Listado Estadistico');
set identity_insert funcionalidades off;

-- funcionalidades por rol
create table funcionalidades_por_rol (
  id_rol int,
  id_funcionalidad int,
  PRIMARY KEY (id_rol, id_funcionalidad),
  FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
  FOREIGN KEY (id_funcionalidad) REFERENCES funcionalidades(id_funcionalidad)
)

insert into funcionalidades_por_rol (id_rol, id_funcionalidad)
values
  (1, 1), -- Admin - ABM Rol
  (1, 2), -- Admin - ABM Usuario
  (2, 3), -- Recepcionista - ABM Cliente
  (1, 4), -- Admin - ABM Hotel
  (1, 5), -- Admin - ABM Habitacion
  (1, 6), -- Admin - ABM Regimen
  (2, 7), -- Recepcionista - Generar o Modificar Reserva
  (3, 7), -- Guest - Generar o Modificar Reserva
  (2, 8), -- Recepcionista - Cancelar Reserva
  (3, 8), -- Guest - Cancelar Reserva
  (2, 9), -- Recepcionista - Registrar Estadia
  (2, 10), -- Recepcionista - Registrar Consumibles
  (2, 11), -- Recepcionista- Facturar Estadia
  (1, 12), -- Admin - Listado Estadistico
  (4, 1), (4, 2), (4, 3), (4, 4), (4, 5),
  (4, 6), (4, 7), (4, 8), (4, 9), (4, 10),
  (4, 11), (4, 12); -- Admin General - Todo

-- estados de cliente
create table estados_de_cliente (
  id_estado_cliente int PRIMARY KEY NOT NULL IDENTITY(1,1),
  descripcion nvarchar(255)
)

set identity_insert estados_de_cliente on;
insert into estados_de_cliente (id_estado_cliente, descripcion)
values (1, 'Habilitado'),
       (2, 'Inhabilitado por email repetido'),
       (3, 'Inhabilitado por pasaporte repetido'),
       (4, 'Inhabilitado por pasaporte y mail repetido');
set identity_insert estados_de_cliente off;

-- tipos_de_identificacion
create table tipos_de_identificacion (
  tipo_identificacion int PRIMARY KEY NOT NULL IDENTITY(1,1),
  descripcion nvarchar(255)
)

set identity_insert tipos_de_identificacion on;
insert into tipos_de_identificacion (tipo_identificacion, descripcion)
values
  (1, 'Pasaporte'),
  (2, 'DNI'),
  (3, 'LC'),
  (4, 'LE');
set identity_insert tipos_de_identificacion off;

-- clientes
create table clientes (
  id_cliente int NOT NULL PRIMARY KEY IDENTITY(1,1),
  nro_identificacion numeric(18,0),
  tipo_identificacion int,
  nombre nvarchar(255),
  apellido nvarchar(255),
  mail nvarchar(255),
  calle nvarchar(255),
  nro_calle numeric(18,0),
  piso numeric(18,0),
  depto nvarchar(50),
  fecha_nacimiento datetime,
  nacionalidad nvarchar(255),
  FOREIGN KEY (tipo_identificacion) REFERENCES tipos_de_identificacion(tipo_identificacion)
);

insert into clientes (nro_identificacion, tipo_identificacion, nombre, apellido, mail, calle, nro_calle, piso, depto, fecha_nacimiento, nacionalidad)
select
  distinct
  Cliente_Pasaporte_Nro as nro_identificacion,
  1 as tipo_identificacion,
  Cliente_Nombre as nombre,
  Cliente_Apellido as apellido,
  Cliente_Mail as mail,
  Cliente_Dom_Calle as calle,
  Cliente_Nro_Calle as nro_calle,
  Cliente_Piso as piso,
  Cliente_Depto as depto,
  Cliente_Fecha_Nac as fecha_nacimiento,
  Cliente_Nacionalidad as nacionalidad
from gd_esquema.Maestra;

alter table clientes
add telefono nvarchar(255),
    localidad nvarchar(255),
    id_estado_cliente int not null default 1;
alter table clientes
add constraint id_estado_cliente
  FOREIGN KEY (id_estado_cliente)
  REFERENCES estados_de_cliente(id_estado_cliente);

-- manejo de clientes con mail o dni repetido
create table #TemporalClientesMailRepetido (email_repetido nvarchar(255))
create table #TemporalClientesPasaporteRepetido (pasaporte_repetido numeric(18,0))

insert into #TemporalClientesMailRepetido (email_repetido)
select distinct
  m1.Cliente_Mail
from gd_esquema.Maestra m1, gd_esquema.Maestra m2
where
  m1.Cliente_Pasaporte_Nro != m2.Cliente_Pasaporte_Nro and
  m1.Cliente_Mail = m2.Cliente_Mail

insert into #TemporalClientesPasaporteRepetido (pasaporte_repetido)
select distinct
  m1.Cliente_Pasaporte_Nro
from gd_esquema.Maestra m1, gd_esquema.Maestra m2
where
  m1.Cliente_Pasaporte_Nro = m2.Cliente_Pasaporte_Nro and
  m1.Cliente_Mail != m2.Cliente_Mail

update clientes
set id_estado_cliente = 2
where mail in (select email_repetido from #TemporalClientesMailRepetido) and
  nro_identificacion not in (select pasaporte_repetido from #TemporalClientesPasaporteRepetido)

update clientes
set id_estado_cliente = 3
where nro_identificacion in (select pasaporte_repetido from #TemporalClientesPasaporteRepetido) and
  mail not in (select email_repetido from #TemporalClientesMailRepetido)

update clientes
set id_estado_cliente = 4
where nro_identificacion in (select pasaporte_repetido from #TemporalClientesPasaporteRepetido) and
  mail in (select email_repetido from #TemporalClientesMailRepetido)

-- hoteles
create table hoteles (
  id_hotel int NOT NULL PRIMARY KEY IDENTITY(1,1),
  calle nvarchar(255),
  ciudad nvarchar(255),
  nro_calle numeric(18,0),
  recarga_estrellas numeric(18,0),
  cant_estrellas numeric(18,0),
  habilitado bit default 1
);

insert into hoteles (calle, ciudad, nro_calle, recarga_estrellas, cant_estrellas)
select
  Hotel_Calle as calle,
  Hotel_Ciudad as ciudad,
  Hotel_Nro_Calle  as nro_calle,
  Hotel_Recarga_Estrella as recarga_estrellas,
  Hotel_CantEstrella as cant_estrellas
from gd_esquema.Maestra
group by
  Hotel_Calle,
  Hotel_Ciudad,
  Hotel_Nro_Calle,
  Hotel_Recarga_Estrella,
  Hotel_CantEstrella;

alter table hoteles
add nombre nvarchar(255),
    fecha_creacion datetime,
    mail nvarchar(255),
    telefono nvarchar(255),
    pais nvarchar(255);

-- bajas_temporales_por_hotel
create table bajas_temporales_por_hotel (
  id_baja int PRIMARY KEY NOT NULL IDENTITY(1,1),
  id_hotel int,
  fecha_inicio datetime default SYSDATETIME(),
  fecha_fin datetime,
  descripcion nvarchar(255),
  FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
)

-- regimenes
create table regimenes (
  id_regimen int NOT NULL PRIMARY KEY IDENTITY(1,1),
  descripcion nvarchar(255),
  precio numeric(18,2)
);

insert into regimenes (descripcion, precio)
select
  Regimen_Descripcion as descripcion,
  Regimen_Precio as precio
from gd_esquema.Maestra
group by Regimen_Descripcion,
  Regimen_Precio;

alter table regimenes
add estado bit;

-- tipo de habitacion
create table tipos_de_habitacion (
  tipo_codigo int NOT NULL PRIMARY KEY IDENTITY(1,1),
  descripcion nvarchar(255),
  porcentual numeric(18,2)
);
set identity_insert tipos_de_habitacion on;
insert into tipos_de_habitacion (tipo_codigo, descripcion, porcentual)
select
  Habitacion_Tipo_Codigo as tipo_codigo,
  Habitacion_Tipo_Descripcion as descripcion,
  Habitacion_Tipo_Porcentual as porcentual
from gd_esquema.Maestra
group by Habitacion_Tipo_Codigo,
  Habitacion_Tipo_Descripcion,
  Habitacion_Tipo_Porcentual;
set identity_insert tipos_de_habitacion off;

alter table tipos_de_habitacion
add cant_huespedes int;

-- cant_huespedes para calculo de precios...
update tipos_de_habitacion
set cant_huespedes = 1
where tipo_codigo = 1001;
update tipos_de_habitacion
set cant_huespedes = 2
where tipo_codigo = 1002;
update tipos_de_habitacion
set cant_huespedes = 3
where tipo_codigo = 1003;
update tipos_de_habitacion
set cant_huespedes = 4
where tipo_codigo = 1004;
update tipos_de_habitacion
set cant_huespedes = 5
where tipo_codigo = 1005;

-- habitaciones

create table habitaciones (
  id_habitacion int NOT NULL PRIMARY KEY IDENTITY(1,1),
  id_hotel int,
  tipo_codigo int,
  frente nvarchar(50),
  numero numeric(18,0),
  piso numeric(18,0),
  FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel),
  FOREIGN KEY (tipo_codigo) REFERENCES tipos_de_habitacion(tipo_codigo),
);

insert into habitaciones (id_hotel, tipo_codigo, frente, numero, piso)
select
  h.id_hotel,
  Habitacion_Tipo_Codigo as tipo_codigo,
  Habitacion_Frente as frente,
  Habitacion_Numero as numero,
  Habitacion_Piso as piso
from gd_esquema.Maestra
join hoteles h on (
  Hotel_Ciudad = h.ciudad and
  Hotel_Calle = h.calle and
  Hotel_Nro_Calle = h.nro_calle)
group by h.id_hotel,
  Habitacion_Tipo_Codigo,
  Habitacion_Frente,
  Habitacion_Numero,
  Habitacion_Piso;

-- regimenes por hotel

create table regimenes_por_hotel (
  id int PRIMARY KEY NOT NULL IDENTITY(1,1),
  id_hotel int,
  id_regimen int,
  FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel),
  FOREIGN KEY (id_regimen) REFERENCES regimenes(id_regimen),
);

insert into regimenes_por_hotel (id_hotel, id_regimen)
select
  h.id_hotel,
  r.id_regimen
from gd_esquema.Maestra
join hoteles h on (
  Hotel_Calle = h.calle and
  Hotel_Ciudad = h.ciudad and
  Hotel_Nro_Calle = h.nro_calle
)
join regimenes r on (
  Regimen_Descripcion = r.descripcion and
  Regimen_Precio = r.precio
)
group by h.id_hotel, r.id_regimen;

-- estados de reserva
create table estados_de_reservas (
  id_estado int PRIMARY KEY NOT NULL IDENTITY(1,1),
  estado nvarchar(255)
)

set identity_insert estados_de_reservas on;
insert into estados_de_reservas (id_estado, estado)
values
  (1, 'Reserva correcta'),
  (2, 'Reserva modificada'),
  (3, 'Reserva cancelada por Recepcion'),
  (4, 'Reserva cancelada por Cliente'),
  (5, 'Reserva cancelada por No-Show'),
  (6, 'Reserva con ingreso'),
  (7, 'Reserva inhabilitada por datos corruptos');
set identity_insert estados_de_reservas off;

-- reservas
create table reservas (
  reserva_codigo int PRIMARY KEY NOT NULL IDENTITY(1,1),
  cant_noches numeric(18,0),
  fecha_inicio datetime,
  id_regimen int,
  FOREIGN KEY (id_regimen) REFERENCES regimenes(id_regimen)
)

set identity_insert reservas on;
insert into reservas (reserva_codigo, cant_noches, fecha_inicio, id_regimen)
select
  distinct Reserva_Codigo reserva_codigo,
  Reserva_Cant_Noches cant_noches,
  Reserva_Fecha_Inicio fecha_inicio,
  r.id_regimen
from gd_esquema.Maestra
join regimenes r on (
  Regimen_Descripcion = r.descripcion and
  Regimen_Precio = r.precio
)
set identity_insert reservas off;

-- estados_por_reserva
create table estados_por_reserva (
  id int PRIMARY KEY NOT NULL IDENTITY(1,1),
  reserva_codigo int,
  id_estado int,
  fecha_modificacion datetime,
  usuario_modificacion nvarchar(255),
  FOREIGN KEY (id_estado) REFERENCES estados_de_reservas(id_estado),
  FOREIGN KEY (reserva_codigo) REFERENCES reservas(reserva_codigo)
)

insert into estados_por_reserva (reserva_codigo, fecha_modificacion, usuario_modificacion)
select
  reserva_codigo,
  SYSDATETIME() as fecha_modificacion,
  'dbo migracion' as usuario_modificacion
from reservas

-- reservas con ingreso (facturadas)
create table #ReservasConIngreso (reserva_codigo int)
insert into #ReservasConIngreso (reserva_codigo)
select distinct
  Reserva_Codigo
from gd_esquema.Maestra
where Factura_Nro is not null and
  Factura_Fecha - Estadia_Fecha_Inicio > Estadia_Cant_Noches and
  Estadia_Fecha_Inicio < SYSDATETIME() and
  Factura_Fecha < SYSDATETIME()

-- reserva con factura del futuro
create table #ReservasCorruptasFacturaFutura (reserva_codigo int)
insert into #ReservasCorruptasFacturaFutura (reserva_codigo)
select distinct
  Reserva_Codigo
from gd_esquema.Maestra
where Factura_Fecha > SYSDATETIME()

-- reserva correcta
create table #ReservasCorrectas (reserva_codigo int)
insert into #ReservasCorrectas (reserva_codigo)
select distinct
  Reserva_Codigo
from gd_esquema.Maestra
where Reserva_Codigo not in (select reserva_codigo from #ReservasConIngreso) and
  Reserva_Codigo not in (select reserva_codigo from #ReservasCorruptasFacturaFutura)

update estados_por_reserva
set id_estado = 6
where reserva_codigo in (select reserva_codigo from #ReservasConIngreso)

update estados_por_reserva
set id_estado = 7
where reserva_codigo in (select reserva_codigo from #ReservasCorruptasFacturaFutura)

update estados_por_reserva
set id_estado = 1
where reserva_codigo in (select reserva_codigo from #ReservasCorrectas)

-- reservas por habitacion
create table reservas_por_habitacion (
  id int PRIMARY KEY NOT NULL IDENTITY(1,1),
  id_habitacion int,
  reserva_codigo int,
  FOREIGN KEY (id_habitacion) REFERENCES habitaciones(id_habitacion),
  FOREIGN KEY (reserva_codigo) REFERENCES reservas(reserva_codigo)
);

insert into reservas_por_habitacion (reserva_codigo, id_habitacion)
select
  Reserva_Codigo as reserva_codigo,
  h2.id_habitacion
from gd_esquema.Maestra
join hoteles h1 on (
  Hotel_Calle = h1.calle and
  Hotel_Ciudad = h1.ciudad and
  Hotel_Nro_Calle = h1.nro_calle
)
join habitaciones h2 on (
  h1.id_hotel = h2.id_hotel and
  Habitacion_Piso = h2.piso and
  Habitacion_Frente = h2.frente and
  Habitacion_Numero = h2.numero
)
group by Reserva_Codigo, h2.id_habitacion;

-- reserva_por_cliente
create table reservas_por_cliente (
  id int PRIMARY KEY NOT NULL IDENTITY(1,1),
  reserva_codigo int,
  id_cliente int,
  FOREIGN KEY (reserva_codigo) REFERENCES reservas(reserva_codigo),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

insert into reservas_por_cliente (id_cliente, reserva_codigo)
select
  c.id_cliente,
  Reserva_Codigo as reserva_codigo
from gd_esquema.Maestra
join clientes c on (
  Cliente_Pasaporte_Nro = c.nro_identificacion
)
group by Reserva_Codigo, c.id_cliente;

-- estadias
create table estadias (
  estadia_codigo int PRIMARY KEY NOT NULL IDENTITY(1,1),
  fecha_ingreso datetime,
  fecha_salida datetime,
  reserva_codigo int,
  dias_efectivos numeric(18,0),
  dias_noefectivos numeric(18,0),
  FOREIGN KEY (reserva_codigo) REFERENCES reservas(reserva_codigo)
);

insert into estadias (reserva_codigo, fecha_ingreso)
select distinct
  Reserva_Codigo as reserva_codigo,
  Estadia_Fecha_Inicio as fecha_ingreso
from gd_esquema.Maestra
where (
  Estadia_Cant_Noches is not null and
  Estadia_Fecha_Inicio is not null
)

-- consumibles
create table consumibles (
  consumible_codigo int PRIMARY KEY NOT NULL IDENTITY(1,1),
  descripcion nvarchar(255),
  precio numeric(18,2)
);

set identity_insert consumibles on;
insert into consumibles (consumible_codigo, descripcion, precio)
select distinct
  Consumible_Codigo as consumible_codigo,
  Consumible_Descripcion as descripcion,
  Consumible_Precio as precio
from gd_esquema.Maestra
where Consumible_Codigo is not null
set identity_insert consumibles off;

-- consumible por estadia
create table consumible_por_estadia (
  id int PRIMARY KEY NOT NULL IDENTITY(1,1),
  consumible_codigo int,
  estadia_codigo int,
  cantidad numeric(18,0),
  FOREIGN KEY (consumible_codigo) REFERENCES consumibles(consumible_codigo),
  FOREIGN KEY (estadia_codigo) REFERENCES estadias(estadia_codigo)
)

insert into consumible_por_estadia (estadia_codigo, consumible_codigo, cantidad)
select
  e.estadia_codigo,
  Consumible_Codigo as consumible_codigo,
  count(Consumible_Codigo) as cantidad
from gd_esquema.Maestra m
join estadias e on (
  e.reserva_codigo = m.Reserva_Codigo
)
where m.Consumible_Codigo is not null
group by e.estadia_codigo, m.Consumible_Codigo

-- facturas
create table facturas (
  id_factura int PRIMARY KEY not null IDENTITY(1,1),
  nro_factura numeric(18,0) not null,
  fecha_factura datetime not null,
  total_factura numeric(18,2),
  consistente bit not null default 1
)

insert into facturas (nro_factura, fecha_factura, total_factura)
select distinct
  Factura_Nro,
  Factura_Fecha,
  Factura_Total
from gd_esquema.Maestra where Factura_Nro is not null

-- items factura
create table items_facturas (
  id_item int PRIMARY KEY NOT NULL IDENTITY(1,1),
  id_factura int,
  monto numeric(18,2),
  cantidad numeric(18,0),
  descripcion nvarchar(255),
  FOREIGN KEY (id_factura) REFERENCES facturas(id_factura)
)

-- insert consumibles en items_facturas
insert into items_facturas (id_factura, descripcion, monto, cantidad)
select
  f.id_factura,
  Consumible_Descripcion as descripcion,
  Item_Factura_Cantidad as monto,
  Item_Factura_Monto as cantidad
from gd_esquema.Maestra
join facturas f on (
  f.nro_factura = Factura_Nro
)
where Consumible_Codigo is not null and Factura_Nro is not null
group by
  f.id_factura,
  Consumible_Descripcion,
  Item_Factura_Cantidad,
  Item_Factura_Monto;

-- inset estadias en item_facturas
insert into items_facturas (id_factura, monto, cantidad, descripcion)
select
  f.id_factura,
  Item_Factura_Cantidad as monto,
  Item_Factura_Monto as cantidad,
  'Estadia de reserva: ' + convert(varchar(18),Reserva_Codigo) as descripcion
from gd_esquema.Maestra
join facturas f on (
  f.nro_factura = Factura_Nro
)
where Consumible_Codigo is null and
  Factura_Nro is not null

--  marcar facturas inconsistentes
update facturas
set consistente = 0
where nro_factura in (
  select f.nro_factura
  from facturas f
  join items_facturas it on (
    it.id_factura = f.id_factura
  )
  group by f.nro_factura, f.total_factura
  having sum(it.monto * it.cantidad) != f.total_factura
)

-- usuarios
create table usuarios (
  id_usuario int PRIMARY KEY NOT NULL IDENTITY(1,1),
  username nvarchar(50),
  password nvarchar(4000),
  habilitado bit default 1
)

-- roles_por_usuario
create table roles_por_usuario (
  id_usuario int,
  id_rol int,
  PRIMARY KEY (id_usuario, id_rol),
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
)

-- insert usuario superadmin
set identity_insert usuarios on;
insert into usuarios (id_usuario, username, password)
values (1, 'admin', hashbytes('SHA2_256','w23e')),
  (2, 'guest', hashbytes('SHA2_256','')), (3, 'multirol', hashbytes('SHA2_256', 'roles'));
set identity_insert usuarios off;

insert into roles_por_usuario (id_usuario, id_rol)
values (1, 4), (2, 3), (3, 1), (3, 4);