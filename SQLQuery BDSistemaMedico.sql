--Creación de esquemas para asignar a las tablas
CREATE SCHEMA Sesion

--Cambiar de esquema la tabla de dbo a Sesion
ALTER SCHEMA Sesion TRANSFER dbo.Menu
ALTER SCHEMA Sesion TRANSFER dbo.MenuPorRol
ALTER SCHEMA Sesion TRANSFER dbo.Modulo
ALTER SCHEMA Sesion TRANSFER dbo.Rol
ALTER SCHEMA Sesion TRANSFER dbo.Token
ALTER SCHEMA Sesion TRANSFER dbo.Usuario

------------------------------------ PROCEDIMIENTOS ALMACENADOS ---------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN USUARIO
ALTER PROC Sesion.AgregarUsuario	(
											@_Nombres			NVARCHAR(50),
											@_Apellidos			NVARCHAR(50),
											@_Direccion			NVARCHAR(MAX),
											@_Email				NVARCHAR(100),
									 		@_Contrasenia		NVARCHAR(MAX)
											--@_Token				NVARCHAR(250)
									)	
AS
DECLARE @_FilasAfectadas	TINYINT
		,@_Resultado		SMALLINT
		,@_UltimoId			SMALLINT
		--,@_IdUsuario			INT
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdUsuario),0)
	FROM	Sesion.Usuario AS a
	
/*	-- VALIDAR USUARIO POR MEDIO DE TOKEN
	SELECT	@_IdUsuario	= b.IdUsuario
	FROM	Sesion.Token AS	b
	WHERE	b.Token = @_Token		*/

	BEGIN TRY
		INSERT INTO Sesion.Usuario	(
										IdUsuario,
										Nombres,
										Apellidos,
										Direccion,
										Email,
										Contrasenia
										--IdUsuarioIngresadoPor
									)
		VALUES						(
										@_UltimoId + 1,
										@_Nombres,
										@_Apellidos,
										@_Direccion,
										@_Email,
										@_Contrasenia
										--@_IdUsuario
									)
		SET @_FilasAfectadas = @@ROWCOUNT -- CUENTA LAS FILAS AFECTADAS
	END TRY

	BEGIN CATCH --SE SETEA EL VALOR DE 0 POR SI NO REALIZA LA TRANSACCIÓN
		SET @_FilasAfectadas = 0
	END CATCH		

--DETERMINAR SI SE REALIZO CORRECTAMENTE LA TRANSACCION ANTERIOR
IF (@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado = @_UltimoId + 1
			COMMIT
		END
	ELSE
		BEGIN
			SET @_Resultado	= 0
			ROLLBACK
		END
	--DEVOLVER RESULTADO: EL ULTIMO ID QUE UTILIZARÉ MÁS ADELANTE
	SELECT Resultado = @_Resultado
END --FIN 

-- Prueba para Agregar Usuario
EXEC Sesion.AgregarUsuario 'Prueba','Juárez','Poptún','prueba@hotmail.com','123'

---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA OBTENER LOS USUARIOS
ALTER PROC Sesion.ObtenerUsuarios
AS
BEGIN
	SELECT
			a.IdUsuario,
			CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
			a.Direccion,
			a.Email,
			a.Contrasenia,
			a.FechaIngreso,
			a.Estado
	FROM Sesion.Usuario AS a
	WHERE a.Estado > 0
END

-- Prueba
EXEC Sesion.ObtenerUsuarios
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA OBTENER UN USUARIO
ALTER PROC Sesion.ObtenerDatosUsuario	(	
											@_IdUsuario INT
										)
AS
BEGIN
	SELECT
			a.IdUsuario
			,a.Nombres
			,a.Apellidos
			,a.Direccion
			,a.Email
			,a.Contrasenia
	FROM	Sesion.Usuario AS a
	WHERE	a.IdUsuario = @_IdUsuario
END

-- Prueba
EXEC Sesion.ObtenerDatosUsuario '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA ELIMINAR UN USUARIO (Cambiar de estado)
ALTER PROC Sesion.EliminarUsuario	(
										@_IdUsuario INT
									)
AS
DECLARE	@_FilasAfectadas					TINYINT
		,@_Resultado						INT
BEGIN
	BEGIN TRAN
		BEGIN TRY	--ACTUALIZAR LA TABLA PARA CAMBIAR DE ESTADO
			UPDATE	Sesion.Usuario
			SET		Estado = 0		
			WHERE	IdUsuario =	@_IdUsuario

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado = @_IdUsuario
			COMMIT
		END
	ELSE
		BEGIN
			SET @_Resultado = 0
			ROLLBACK
		END

	SELECT	Resultado =	@_Resultado
END

-- Prueba
EXEC Sesion.EliminarUsuario '1'
--------------------------------------------------------------------------------------------------------------------
/*
	AUTOR:		Daniel Juárez
	FECHA:		15/08/2020
*/

--PROCEDIMIENTO PARA MODIFICAR/ACTUALIZAR UN USUARIO
ALTER PROC Sesion.ModificarUsuario	(
										@_IdUsuario		INT,
										@_Nombres		NVARCHAR(50),
										@_Apellidos		NVARCHAR(50),
										@_Direccion		NVARCHAR(MAX),
										@_Email			NVARCHAR(100),
										@_Contrasenia	NVARCHAR(MAX)
									)
AS
DECLARE	@_FilasAfectadas					TINYINT
		,@_Resultado						INT
BEGIN
	BEGIN TRAN
		BEGIN TRY
			UPDATE	Sesion.Usuario
			SET		
					Nombres			=	@_Nombres,
					Apellidos		=	@_Apellidos,
					Direccion		=	@_Direccion,
					Email			=	@_Email,
					Contrasenia		=	@_Contrasenia
			WHERE	IdUsuario		=	@_IdUsuario

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY
		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= @_IdUsuario
			COMMIT
		END
	ELSE
		BEGIN
			SET @_Resultado	= 0
			ROLLBACK
		END

	SELECT	Resultado =	@_Resultado
END

-- Prueba
EXEC Sesion.ModificarUsuario '1', 'Daniel','Juárez','Poptún','prueba@hotmail.com','123'