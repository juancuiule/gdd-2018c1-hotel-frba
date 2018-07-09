drop table if exists clientes;
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