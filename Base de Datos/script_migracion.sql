drop table if exists regimenes_por_hotel;
drop table if exists estados_por_reserva;
drop table if exists reservas_por_habitacion;
drop table if exists reservas_por_cliente;
drop table if exists habitaciones;
drop table if exists clientes;
drop table if exists estados_de_cliente;

drop table if exists reservas;
drop table if exists estados_de_reservas;
drop table if exists hoteles;
drop table if exists regimenes;
drop table if exists tipos_de_habitacion;

drop table if exists #TemporalClientesMailRepetido
drop table if exists #TemporalClientesPasaporteRepetido

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

-- clientes
create table clientes (
  id_cliente int NOT NULL PRIMARY KEY IDENTITY(1,1),
  pasaporte_nro numeric(18,0),
  nombre nvarchar(255),
  apellido nvarchar(255),
  mail nvarchar(255),
  calle nvarchar(255),
  nro_calle numeric(18,0),
  piso numeric(18,0),
  depto nvarchar(50),
  fecha_nacimiento datetime,
  nacionalidad nvarchar(255)
);

insert into clientes (pasaporte_nro, nombre, apellido, mail, calle, nro_calle, piso, depto, fecha_nacimiento, nacionalidad)
select
  distinct
  Cliente_Pasaporte_Nro as pasaporte_nro,
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
  pasaporte_nro not in (select pasaporte_repetido from #TemporalClientesPasaporteRepetido)

update clientes
set id_estado_cliente = 3
where pasaporte_nro in (select pasaporte_repetido from #TemporalClientesPasaporteRepetido) and
  mail not in (select email_repetido from #TemporalClientesMailRepetido)

update clientes
set id_estado_cliente = 4
where pasaporte_nro in (select pasaporte_repetido from #TemporalClientesPasaporteRepetido) and
  mail in (select email_repetido from #TemporalClientesMailRepetido)

-- hoteles
create table hoteles (
  id_hotel int NOT NULL PRIMARY KEY IDENTITY(1,1),
  calle nvarchar(255),
  ciudad nvarchar(255),
  nro_calle numeric(18,0),
  recarga_estrellas numeric(18,0),
  cant_estrellas numeric(18,0)
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
  (3, 'Reserva cancelada por Recepción'),
  (4, 'Reserva cancelada por Cliente'),
  (5, 'Reserva cancelada por No-Show'),
  (6, 'Reserva con ingreso');
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

insert into estados_por_reserva (reserva_codigo, id_estado, fecha_modificacion, usuario_modificacion)
select
  reserva_codigo,
  1 as id_estado,
  SYSDATETIME() as fecha_modificacion,
  'dbo migracion' as usuario_modificacion
from reservas


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
  Cliente_Pasaporte_Nro = c.pasaporte_nro
)
group by Reserva_Codigo, c.id_cliente;

-- estadias
-- create table estadias (
--   estadia_codigo int PRIMARY KEY NOT NULL IDENTITY(1,1),
--   fecha_ingreso datetime,
--   fecha_salida datetime,
--   reserva_codigo int,
--   dias_efectivos numeric(18,0),
--   dias_noefectivos numeric(18,0),
--   FOREIGN KEY (reserva_codigo) REFERENCES reservas(reserva_codigo)
-- );

-- select
--   distinct Reserva_Codigo as reserva_codigo,
--   Estadia_Fecha_Inicio as fecha_ingreso
-- from gd_esquema.Maestra
-- where (
--   Estadia_Cant_Noches is not null and
--   Estadia_Fecha_Inicio is not null
-- )
-- order by Reserva_Codigo