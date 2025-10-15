USE MASTER
GO

/* ELIMINA BASE BikeZ_DW, SI EXISTE */
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BikeZ_DW')
BEGIN
    ALTER DATABASE BikeZ_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BikeZ_DW;
END


/* CREACION DE LA BASE DE DATOS DEL DATAWAREHOUSE 
                                                
   considera 5 Dimensiones : Producto, Clientes, Empleado, Territorio y TIEMPO 
             1 Tabla de Hechos : VENTAS                                      
*/
create database BikeZ_DW;
go

use BikeZ_DW
go

-- ====================================================================
-- Creación Tabla DIMENSION PRODUCTO
-- ====================================================================
CREATE TABLE DIMProducto (
    productokey				INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    producto_id				int not null,
    producto_nombre			nvarchar(50) not null,
    producto_color			nvarchar(15) not null,
	producto_categoria		nvarchar(50) not null,
	fecha_ini  	 			date not null ,
	fecha_fin				date not null
);

/* Creación Tabla DIMENSION CLIENTE */
CREATE TABLE DIMCliente (
    clientekey					INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    cliente_id					INT not null,
	cliente_nombre				nvarchar(255) not null,
	cliente_sexo				nchar(1) not null,
	cliente_estado_civil		nchar(10) not null,
	fecha_ini					date not null ,
	fecha_fin					date not null
);

/* Creación Tabla DIMENSION EMPLEADO */
CREATE TABLE DIMEmpleado (
    empleadokey					INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
	empleado_id					INT not null,
	empleado_cargo				nvarchar(50) not null,
	empleado_nacimiento			date not null,
	empleado_estado_civil		nchar(1) not null,
	empleado_sexo				nchar(1) not null,
	empleado_contratacion		date not null,
	empleado_horas_vacaciones	smallint not null,
	empleado_territorio			nvarchar(50) not null,
	empleado_grupo				nvarchar(50) not null,
	empleado_pais				nvarchar(50) not null,
	fecha_ini					date not null ,
	fecha_fin					date not null
);

/* Creación Tabla DIMENSION TERRITORIO */
CREATE TABLE DIMTerritorio (
    territoriokey				INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
	territorio_id				int not null,
    territorio_nombre			nvarchar(255) not null,
	territorio_grupo			nvarchar(255) not null,
	territorio_pais				nvarchar(50) not null,
	fecha_ini					date not null,
	fecha_fin					date not null
);

/* Creación Tabla DIMENSION TIEMPO  */
CREATE TABLE DIMTiempo (
    tiempokey		INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    fecha			date not null,
	fechaAAAAMMDD	INT  not null,
	año				smallint not null,
	semestre		smallint not null,
	trimestre		smallint not null,
	mes				smallint not null,
	semana			smallint not null,
	dia				smallint not null,
	diasemana		smallint not null,
	nsemestre		varchar(15) not null,
	ntrimestre		varchar(15) not null,
	nmes			varchar(15) not null,
	nmes3L			varchar(15) not null,
	ndiasemana		varchar(15) not null,
    ndiasemana3L	varchar(15)  not null
);

/* Creación Tabla HECHOS VENTAS  */
CREATE TABLE HECHOSVentas (
    tiempokey				INT not null,
	productokey				INT not null,
    territoriokey			INT not null,
    clientekey				INT not null,
    empleadokey				INT not null,
    total_neto				INT not null,			/* ( PRECIO UNITARIO * CANTIDAD ) / 1,19 */
    total_impuesto			INT not null,			/* ( PRECIO UNITARIO * CANTIDAD ) * 19%  */
    total_bruto				INT not null,           /*   PRECIO UNITARIO * CANTIDAD          */ 
	total_cantidad			INT not null			/*   CANTIDAD                            */
);

-- ====================================================================================
-- DEFINICION DE RELACIONES ENTRE DIMENSIONES Y HECHOS
-- ====================================================================================

EXEC SYS.sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO

ALTER TABLE HECHOSVentas
ADD FOREIGN KEY (productokey)	REFERENCES DIMProducto   (productokey);

ALTER TABLE HECHOSVentas
ADD FOREIGN KEY (tiempokey)		REFERENCES DIMTiempo     (tiempokey);

ALTER TABLE HECHOSVentas
ADD FOREIGN KEY (territoriokey)	REFERENCES DIMTerritorio (territoriokey);

ALTER TABLE HECHOSVentas
ADD FOREIGN KEY (clientekey)	REFERENCES DIMcliente    (clientekey);

ALTER TABLE HECHOSVentas
ADD FOREIGN KEY (empleadokey)	REFERENCES DIMEmpleado   (empleadokey);
go

-- CREACION DE INDICES DE LAS TABLAS 
----------------------------------------------------

CREATE CLUSTERED	INDEX I_DIMProducto_nombre	 ON DIMProducto   (producto_nombre);

CREATE CLUSTERED	INDEX I_DIMCliente_nombre	 ON DIMCliente    (cliente_nombre);

CREATE CLUSTERED	INDEX I_DIMEmpleado_nombre	 ON DIMEmpleado	  (empleado_cargo);

CREATE CLUSTERED	INDEX I_DIMTerritorio_nombre ON DIMTerritorio (territorio_nombre);

CREATE CLUSTERED	INDEX I_DIMTiempo_fecha		 ON DIMtiempo     (fecha);

go


