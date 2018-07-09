-- clientes
drop table if exists clientes;
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
drop table if exists hoteles;
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