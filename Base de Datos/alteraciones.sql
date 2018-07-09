alter table clientes
add telefono nvarchar(255),
    localidad nvarchar(255);

alter table hoteles
add nombre nvarchar(255),
    fecha_creacion datetime,
    mail nvarchar(255),
    telefono nvarchar(255),
    pais nvarchar(255);

alter table regimenes
add estado bit;