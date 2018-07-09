drop table if exists clientes;
drop table if exists habitaciones;
drop table if exists regimenes_por_hotel;

drop table if exists hoteles;
drop table if exists regimenes;
drop table if exists tipos_de_habitacion;


-- clientes
create table clientes (
  pasaporte_nro numeric(18,0),
  nombre nvarchar(255),
  apellido nvarchar(255),
  mail nvarchar(255),
  calle nvarchar(255),
  nro_calle numeric(18,0),
  piso numeric(18,0),
  depto nvarchar(50),
  fecha_nacimiento datetime,
  nacionalidad nvarchar(255),
  id_cliente int NOT NULL PRIMARY KEY IDENTITY(1,1)
);

insert into clientes
select
  distinct Cliente_Pasaporte_Nro as pasaporte_nro,
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
    localidad nvarchar(255);

-- hoteles
create table hoteles (
  calle nvarchar(255),
  ciudad nvarchar(255),
  nro_calle numeric(18,0),
  recarga_estrellas numeric(18,0),
  cant_estrellas numeric(18,0),
  id_hotel int NOT NULL PRIMARY KEY IDENTITY(1,1)
);

insert into hoteles
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
  descripcion nvarchar(255),
  precio numeric(18,2),
  id_regimen int NOT NULL PRIMARY KEY IDENTITY(1,1)
);

insert into regimenes
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
  id_hotel int,
  tipo_codigo int,
  frente nvarchar(50),
  numero numeric(18,0),
  piso numeric(18,0),
  id_habitacion int NOT NULL PRIMARY KEY IDENTITY(1,1),
  FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel),
  FOREIGN KEY (tipo_codigo) REFERENCES tipos_de_habitacion(tipo_codigo),
);

insert into habitaciones
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
GROUP by h.id_hotel,
  Habitacion_Tipo_Codigo,
  Habitacion_Frente,
  Habitacion_Numero,
  Habitacion_Piso;

-- regimenes por hotel

create table regimenes_por_hotel (
  id_hotel int,
  id_regimen int,
  id int PRIMARY KEY NOT NULL IDENTITY(1,1),
  FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel),
  FOREIGN KEY (id_regimen) REFERENCES regimenes(id_regimen),
);

insert into regimenes_por_hotel
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
);