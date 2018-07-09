// clientes
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
add telefono nvarchar(255);
alter table clientes
add localidad nvarchar(255);