--Creación de esquemas para asignar a las tablas
CREATE SCHEMA Sesion

--Cambiar de esquema la tabla de dbo a Sesion
ALTER SCHEMA Sesion TRANSFER dbo.Menu
ALTER SCHEMA Sesion TRANSFER dbo.MenuPorRol
ALTER SCHEMA Sesion TRANSFER dbo.Modulo
ALTER SCHEMA Sesion TRANSFER dbo.Rol
ALTER SCHEMA Sesion TRANSFER dbo.Token
ALTER SCHEMA Sesion TRANSFER dbo.Usuario

------------------------------------ PROCEDIMIENTOS ALMACENADOS SESION---------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN USUARIO
ALTER PROC Sesion.AgregarUsuario	(
											@_Nombres		NVARCHAR(50),
											@_Apellidos		NVARCHAR(50),
											@_Direccion		NVARCHAR(MAX),
											@_Email			NVARCHAR(100),
									 		@_Contrasenia	NVARCHAR(MAX)
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
EXEC Sesion.AgregarUsuario 'Daniel','Juárez','Poptún','prueba@hotmail.com','123'

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
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

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
--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA INICIAR SESIÓN
ALTER PROC Sesion.IniciarSesion	(
										@_Email				NVARCHAR(100),
										@_Contrasenia		NVARCHAR(130),
										@_Token				NVARCHAR(250),
										@_VigenciaMinutos	INT
									)
AS
DECLARE @_IdUsuario			INT				= 0,
		@_Usuario			NVARCHAR(100)	= '',
		@_UltimoId			INT				= 0,
		@_Resultado			TINYINT			= 0,
		@_FilasAfectadas	TINYINT			= 0,
		@_IdRol				INT				= 0
-- OBTENER Y VALIDAR DATOS PARA LOGIN
BEGIN
	SELECT
			@_IdUsuario			=	a.IdUsuario,
			@_Usuario			=	CONCAT(a.Nombres,' ',a.Apellidos),
			@_IdRol				=	a.IdRol
	FROM	Sesion.Usuario		AS	a
	WHERE	a.Email				=	@_Email
			AND a.Contrasenia	=	@_Contrasenia
			AND	a.Estado		=	1

-- VALIDAR Y CREAR TOKEN
	BEGIN TRAN

		SELECT	@_UltimoId		=	ISNULL(MAX(a.IdToken),0)
		FROM	Sesion.Token	AS	a

		--SI EXISTE UN TOKEN YA ACTIVO PARA EL USUARIO, QUE SE ESTABLEZCA EN 0 PARA AGREGARLE EL NUEVO
		UPDATE	Sesion.Token
		SET		Estado = 0
		WHERE	IdUsuario =	@_IdUsuario
				AND Estado > 0

	--AGREGAR EL NUEVO TOKEN
	BEGIN TRY
		INSERT	INTO Sesion.Token	(
										IdToken,
										IdUsuario,
										Token,
										VigenciaMinutos
									)
		VALUES						(
										@_UltimoId + 1,
										@_IdUsuario,
										@_Token,
										@_VigenciaMinutos
									)
		SET		@_FilasAfectadas = @@ROWCOUNT
	END TRY
	BEGIN CATCH
		SET		@_FilasAfectadas = 0
	END CATCH

	--DETERMINAR SI SE REALIZÓ CORRECTAMENTE LA TRANSACCIÓN
	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= 1
			COMMIT
		END
	ELSE
		BEGIN
			SET @_Resultado	= 0
			SET @_Token		= 'Usuario o contraseña inválida'
			ROLLBACK
		END

	--DEVOLVER RESULTADO
	SELECT
		Resultado	=	@_Resultado,
		Token		=	@_Token,
		Usuario		=	@_Usuario,
		IdRol		=	@_IdRol
END

--Prueba
EXEC Sesion.IniciarSesion 'alexjr64@hotmail.com', '1234', 'hola', '30' 

-------------------------------------------------FUNCIÓN SESION-------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

-- FUNCIÓN PARA VERIFICAR SI EL TOKEN NO HA EXPIRADO
ALTER FUNCTION Sesion.VerificarVigenciaToken	(
													@_Token	NVARCHAR(250)
												)
RETURNS TINYINT
AS
BEGIN
	DECLARE @_Resultado					TINYINT		= 0
			,@_VigenciaMinutos			INT			= 30
			,@_FechaYHoraDeCreacion		DATETIME	= '2001-01-01 01:01:01:001'
			,@_FechaYHoraActual			DATETIME	= getdate()
			,@_TiempoDeUsoEnMinutos		INT			= 0
	
	-- OBTENER DATOS PARA VERIFICAR SI AÚN ESTÁ ACTIVO
	SELECT
			@_VigenciaMinutos		=	a.VigenciaMinutos
			,@_FechaYHoraDeCreacion	=	a.FechaIngreso
	FROM	Sesion.Token AS	a
	WHERE	a.Token	= @_Token
			AND a.Estado = 1
	
	-- VERIFICAR CUANTO TIEMPO LLEVA ACTIVO EL TOKEN EN MINUTOS
	SET		@_TiempoDeUsoEnMinutos = DATEDIFF(MINUTE, @_FechaYHoraDeCreacion, @_FechaYHoraActual)

	-- VERIFICAR SI NO HA EXCEDIDO EL TIEMPO DE VIGENCIA DE TOKEN
	IF(@_TiempoDeUsoEnMinutos > @_VigenciaMinutos)
		BEGIN
			SET	@_Resultado	= 0 --SI SE EXCEDE, RETORNA 0
		END
	ELSE
		BEGIN
			SET @_Resultado	= 1 --SI ESTÁ VIGENTE AÚN, RETORNA 1
		END

	RETURN @_Resultado
END

------------------------------------------------PROCEDIMIENTOS ALMACENADOS SESION--------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

-- PROCEDIMIENTO ACTUALIZAR LA VIGENCIA DEL TOKEN EN CADA TRANSACCIÓN 
CREATE PROC Sesion.ActualizarVigenciaToken	(
												@_Token	NVARCHAR(250)
											)
AS
BEGIN
	-- ELIMINAR TOKENS EXPIRADOS (EVITAR QUE LA TABLA CREZCA INDEFINIDAMENTE)
	DELETE	Sesion.Token
	WHERE	Estado = 0

	-- ACTUALIZAR TOKEN VIGENTE
	UPDATE Sesion.Token
	SET		FechaIngreso = getdate()
	WHERE	Token =	@_Token
			AND	Estado = 1
END

--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

-- OBTENER ESTADO DEL TOKEN
CREATE PROC Sesion.ObtenerEstadoToken	(
											@_Token	NVARCHAR(250)
										)
AS
DECLARE @_EstadoToken	TINYINT	= 0
BEGIN
	--0 = Expirado, 1 = Vigente
	SELECT @_EstadoToken = Sesion.VerificarVigenciaToken(@_Token)

	IF(@_EstadoToken = 1)
		BEGIN
			-- Actualizar la vigencia del token
			EXEC Sesion.ActualizarVigenciaToken	@_Token
		END

	SELECT EstadoToken = @_EstadoToken
END

--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

-- FUNCIÓN PARA OBTENER EL ID DEL USUARIO EN BASE AL TOKEN ENVIADO
CREATE FUNCTION Sesion.ObtenerIdUsuario(
											@_Token	NVARCHAR(250)
										 )
RETURNS INT
AS
BEGIN
	DECLARE @_IdUsuario INT	= 0

	SELECT	@_IdUsuario	= a.IdUsuario	
	FROM	Sesion.Token AS	a
	WHERE	a.Token		 = @_Token
			AND	a.Estado = 1

	RETURN @_IdUsuario
END

