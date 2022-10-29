--Creación de esquemas para asignar a las tablas
CREATE SCHEMA Sesion

CREATE SCHEMA Atencion

CREATE SCHEMA Compra

--Cambiar de esquema la tabla de dbo a Sesion
ALTER SCHEMA Sesion TRANSFER dbo.Menu
ALTER SCHEMA Sesion TRANSFER dbo.MenuPorRol
ALTER SCHEMA Sesion TRANSFER dbo.Modulo
ALTER SCHEMA Sesion TRANSFER dbo.Rol
ALTER SCHEMA Sesion TRANSFER dbo.Token
ALTER SCHEMA Sesion TRANSFER dbo.Usuario

--Cambiar de esquema la tabla de dbo a Atencion
ALTER SCHEMA Atencion TRANSFER dbo.Paciente
ALTER SCHEMA Atencion TRANSFER dbo.HistorialMedico

--Cambiar de esquema la tabla de dbo a Compra
ALTER SCHEMA Compra TRANSFER dbo.Proveedor
ALTER SCHEMA Compra TRANSFER dbo.CitaProveedor
ALTER SCHEMA Compra TRANSFER dbo.CompraProveedor
ALTER SCHEMA Compra TRANSFER dbo.Pago
ALTER SCHEMA Compra TRANSFER dbo.EstadoCompra


------------------------------------ PROCEDIMIENTOS ALMACENADOS SESION---------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN USUARIO
ALTER PROC Sesion.AgregarUsuario	(
											@_Nombres		NVARCHAR(50),
											@_Apellidos		NVARCHAR(50),
											@_Direccion		NVARCHAR(MAX),
											@_Email			NVARCHAR(100),
									 		@_Contrasenia	NVARCHAR(MAX),
											@_IdRol			INT,
											@_Token			NVARCHAR(250)
									)	
AS
DECLARE @_FilasAfectadas	TINYINT,
		@_Resultado			SMALLINT,
		@_UltimoId			SMALLINT,
		@_IdUsuario			INT,
		@_EmailRepetido		NVARCHAR(100)
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdUsuario),0)
	FROM	Sesion.Usuario AS a
	
	-- VALIDAR USUARIO POR MEDIO DE TOKEN
	SELECT	@_IdUsuario	= b.IdUsuario
	FROM	Sesion.Token AS	b
	WHERE	b.Token = @_Token

	-- OBTENER CORREO SI YA EXISTE
	SELECT	@_EmailRepetido = Email
	FROM	Sesion.Usuario
	WHERE	Email = @_Email

	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_Direccion = ''
		OR @_Email = ''
		--OR @_Contrasenia = ''
		OR @_IdRol = '')
			BEGIN
				SELECT Alerta = 'Campos vacíos'
			END

	IF (@_Email = @_EmailRepetido)
		BEGIN
			SELECT Alerta = 'El correo ya está registrado'
		END

	ELSE	-- SI EL CORREO NO EXISTE, REALIZA EL INSERT
		BEGIN TRY
			INSERT INTO Sesion.Usuario	(
										IdUsuario,
										Nombres,
										Apellidos,
										Direccion,
										Email,
										Contrasenia,
										IdUsuarioCreadoPor,
										IdRol
										)
			VALUES						(
										@_UltimoId + 1,
										@_Nombres,
										@_Apellidos,
										@_Direccion,
										@_Email,
										@_Contrasenia,
										@_IdUsuario,
										@_IdRol
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
EXEC Sesion.AgregarUsuario 'Prueba','Prueba','Poptún','prueba@hotmail.com','123'

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
			b.Nombre AS NombreRol,
			a.FechaIngreso,
			a.Estado

	FROM Sesion.Usuario AS a
	LEFT JOIN Sesion.Rol AS b
	ON b.IdRol = a.IdRol
	WHERE a.Estado > 0
	ORDER BY a.Nombres
	
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
			a.IdUsuario,
			a.Nombres,
			a.Apellidos,
			a.Direccion,
			a.Email,
			a.IdRol

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
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
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
										@_Contrasenia	NVARCHAR(MAX),
										@_IdRol			INT
									)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT,
		@_EmailRepetido		NVARCHAR(100)
BEGIN
	BEGIN TRAN

	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_Direccion = ''
		OR @_Email = ''
		--OR @_Contrasenia = ''
		OR @_IdRol = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos o el correo ya está registrado'
		END

	ELSE
		BEGIN TRY
			UPDATE	Sesion.Usuario
			SET		
					Nombres			=	@_Nombres,
					Apellidos		=	@_Apellidos,
					Direccion		=	@_Direccion,
					Email			=	@_Email,
					Contrasenia		=	@_Contrasenia,
					IdRol			=	@_IdRol
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
ALTER FUNCTION Sesion.ObtenerIdUsuario(
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

--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/07/2022			*/
-- SP PARA GENERAR MENU CON OPCIONES DE ACCESO
CREATE PROC Sesion.MenuUsuario	(
										@_Token			NVARCHAR(250)
										,@_IdModulo		TINYINT
									)
AS
DECLARE		@_IdUsuario INT	= 0
BEGIN

	SELECT	@_IdUsuario	= Sesion.ObtenerIdUsuario(@_Token)
	
	SELECT
			b.IdMenu
			,a.TxtNombre
			,a.TxtLink
			,a.IdMenuPadre
			,a.TxtImagen
			,b.Agregar
			,b.ModificarActualizar
			,b.Eliminar
			,b.Consultar
			,b.Imprimir
			,b.Reservar
			,b.Aprobar
			,b.Finalizar
	FROM
			Sesion.TblMenus							AS	a
			LEFT JOIN Sesion.TblRolesPorMenus		AS	b
			ON a.IdMenu								=	b.IdMenu
			LEFT JOIN Sesion.TblRoles				AS	c
			ON c.IdRol								=	b.IdRol
			LEFT JOIN Sesion.TblUsuariosPorRoles	AS	d
			ON d.IdRol								=	c.IdRol
			LEFT JOIN Sesion.TblUsuarios			AS	e
			ON e.IdUsuario							=	c.IdUsuario
	WHERE
			a.IntEstado								=	1
			AND a.IdModulo							=	@_IdModulo
			AND b.IntEstado							=	1
			AND c.IntEstado							=	1
			AND d.IntEstado							=	1
			AND e.IntEstado							=	1
			AND	d.IdUsuario							=	@_IdUsuario
	ORDER BY
			A.DblOrden								ASC

END

------------------------------------ PROCEDIMIENTOS ALMACENADOS ESQUEMA ATENCION---------------------------------------------
/*================================================== TABLA PACIENTES ==================================================*/
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN PACIENTE
ALTER PROC Atencion.AgregarPaciente	(
											@_Nombres			NVARCHAR(50),
											@_Apellidos			NVARCHAR(50),
											@_FechaNacimiento	DATE,
											@_Direccion			NVARCHAR(MAX),
											@_Sexo				NVARCHAR(1),
											@_Telefono			INT,
											@_Token				NVARCHAR(250)
									)	
AS
DECLARE @_FilasAfectadas				TINYINT,
		@_Resultado						SMALLINT,
		@_UltimoId						SMALLINT,
		@_IdUsuario						INT
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdPaciente),0)
	FROM	Atencion.Paciente AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	=	Sesion.ObtenerIdUsuario(@_Token)

	-- IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_FechaNacimiento = ''
		OR @_Direccion = ''
		OR @_Sexo = ''
		OR @_Telefono = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END

	ELSE
		BEGIN TRY
				INSERT INTO Atencion.Paciente	(
												IdPaciente,
												Nombres,
												Apellidos,
												FechaNacimiento,
												Direccion,
												Sexo,
												Telefono,
												IdUsuarioCreadoPor
												)
				VALUES							(
												@_UltimoId + 1,
												@_Nombres,
												@_Apellidos,
												@_FechaNacimiento,
												@_Direccion,
												@_Sexo,
												@_Telefono,
												@_IdUsuario
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

-- Prueba para Agregar Paciente
EXEC Atencion.AgregarPaciente 'Prueba','Prueba','01/05/1999','Poptún','M','11223344','KnetRkXOZsqQanMnra9X381o2TxRZ85EO2K05I8ERN197D9684om04u6jYLZM9O66Fb8MHKHFgYLZSAMfQ'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA OBTENER LOS PACIENTES
ALTER PROC Atencion.ObtenerPacientes (
										@_Busqueda VARCHAR(100)=NULL
									 )
AS
BEGIN
	IF(@_Busqueda IS NULL)
	BEGIN
		SELECT
				a.IdPaciente,
				CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
				a.FechaNacimiento,
				a.Direccion,
				a.Sexo,
				a.Telefono,
				a.FechaIngreso,
				a.Estado
		FROM Atencion.Paciente AS a
		WHERE a.Estado > 0	
	END

	ELSE
	BEGIN
		SELECT
				TOP 5
				a.IdPaciente,
				CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
				a.FechaNacimiento,
				a.Direccion,
				a.Sexo,
				a.Telefono,
				a.FechaIngreso,
				a.Estado
		FROM Atencion.Paciente AS a
		WHERE CONCAT(a.Nombres,' ',a.Apellidos) like CONCAT('%', @_Busqueda, '%')
		AND a.Estado > 0
	END
END

-- Prueba
EXEC Atencion.ObtenerPacientes ''
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA OBTENER SOLO 1 PACIENTE
ALTER PROC Atencion.ObtenerUnPaciente	(	
											@_IdPaciente INT
										)
AS
BEGIN
	SELECT
			a.IdPaciente,
			CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
			a.FechaNacimiento,
			a.Direccion,
			a.Sexo,
			a.Telefono

	FROM	Atencion.Paciente AS a
	WHERE	a.IdPaciente = @_IdPaciente
END

-- Prueba
EXEC Atencion.ObtenerUnPaciente '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA OBTENER DATOS DE UN PACIENTE
ALTER PROC Atencion.ObtenerDatosPaciente	(	
											@_IdPaciente INT
											)
AS
BEGIN
	SELECT
			a.IdPaciente,
			a.Nombres,
			a.Apellidos,
			a.FechaNacimiento,
			a.Direccion,
			a.Sexo,
			a.Telefono

	FROM	Atencion.Paciente AS a
	WHERE	a.IdPaciente = @_IdPaciente
END

-- Prueba
EXEC Atencion.ObtenerDatosPaciente '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA ELIMINAR UN PACIENTE (Cambiar de estado)
ALTER PROC Atencion.EliminarPaciente	(
										@_IdPaciente INT
										)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
BEGIN
	BEGIN TRAN
		BEGIN TRY	--ACTUALIZAR LA TABLA PARA CAMBIAR DE ESTADO
			UPDATE	Atencion.Paciente
			SET		Estado = 0		
			WHERE	IdPaciente = @_IdPaciente

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado = @_IdPaciente
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
EXEC Atencion.EliminarPaciente '1'
--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA MODIFICAR/ACTUALIZAR UN PACIENTE
ALTER PROC Atencion.ModificarPaciente	(
										@_IdPaciente		INT,
										@_Nombres			NVARCHAR(50),
										@_Apellidos			NVARCHAR(50),
										@_FechaNacimiento	DATE,
										@_Direccion			NVARCHAR(MAX),
										@_Sexo				NVARCHAR(1),
										@_Telefono			INT
										)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
		--@_EmailRepetido		NVARCHAR(100)
BEGIN
	BEGIN TRAN
	-- IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_FechaNacimiento = ''
		OR @_Direccion = ''
		OR @_Sexo = ''
		OR @_Telefono = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END

	ELSE
		BEGIN TRY
			UPDATE	Atencion.Paciente
			SET		
					Nombres			=	@_Nombres,
					Apellidos		=	@_Apellidos,
					FechaNacimiento	=	@_FechaNacimiento,
					Direccion		=	@_Direccion,
					Sexo			=	@_Sexo,
					Telefono		=	@_Telefono
			WHERE	IdPaciente		=	@_IdPaciente

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= @_IdPaciente
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
EXEC Atencion.ModificarPaciente '2', 'Carlos','Mayén','10/05/1996','Poptún','M','12345678'

/*================================================== TABLA HISTORIAL MÉDICO ==================================================*/
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN HISTORIAL MÉDICO
ALTER PROC Atencion.AgregarHistorialMedico	(
											@_IdPaciente				INT,
											@_PesoLibras				DECIMAL(4, 1),
											@_AlturaCentimetros			INT,
											@_PresionArterial			NVARCHAR(10),
											@_FrecuenciaCardiaca		INT,
											@_FrecuenciaRespiratoria	INT,
											@_TemperaturaCelsius		DECIMAL(3,1),
											@_MotivoConsulta			NVARCHAR(MAX),
											@_Diagnostico				NVARCHAR(MAX),
											@_Tratamiento				NVARCHAR(MAX),
											@_Comentario				NVARCHAR(MAX),
											@_Token						NVARCHAR(250)
											)	
AS
DECLARE @_FilasAfectadas				TINYINT,
		@_Resultado						SMALLINT,
		@_UltimoId						SMALLINT,
		@_IdUsuario						INT
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdHistorialMedico),0)
	FROM	Atencion.HistorialMedico AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	=	Sesion.ObtenerIdUsuario(@_Token)

	 --IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	--IF(	@_PesoLibras = ''
	IF (@_AlturaCentimetros = ''
		OR @_PresionArterial = ''
		OR @_FrecuenciaCardiaca = ''
		OR @_FrecuenciaRespiratoria = ''
		--OR @_TemperaturaCelsius = ''
		OR @_MotivoConsulta = ''
		OR @_Diagnostico = ''
		OR @_Tratamiento = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END

	ELSE
		BEGIN TRY
				INSERT INTO Atencion.HistorialMedico	(
														IdHistorialMedico,
														IdPaciente,
														PesoLibras,
														AlturaCentimetros,
														PresionArterial,
														FrecuenciaCardiaca,
														FrecuenciaRespiratoria,
														TemperaturaCelsius,
														MotivoConsulta,
														Diagnostico,
														Tratamiento,
														Comentario,
														IdUsuarioCreadoPor
														)
				VALUES									(
														@_UltimoId + 1,
														@_IdPaciente,
														@_PesoLibras,
														@_AlturaCentimetros,
														@_PresionArterial,
														@_FrecuenciaCardiaca,
														@_FrecuenciaRespiratoria,
														@_TemperaturaCelsius,
														@_MotivoConsulta,
														@_Diagnostico,
														@_Tratamiento,
														@_Comentario,
														@_IdUsuario
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

-- Prueba para Agregar Historial Médico
EXEC Atencion.AgregarHistorialMedico '1','150.8','173','120/80','80','20','37.2','Fiebre de 6 días de evolución',
	'Amigdalitis Crónica','Ceftriaxona','Alérgica a los antibióticos','vrLuSP1aMAD0xXPftBYGMCisg1a9BXUVCLAYzqvSsHuoulDKw3qldkJw0v0B718ASQr32NBMr0a3KZL0WuA'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA OBTENER LOS HISTORIALES MEDICOS DE UN PACIENTE
ALTER PROC Atencion.ObtenerHistorialesMedicosPaciente (
														@_IdPaciente INT
														)
AS
BEGIN
	SELECT
			a.IdHistorialMedico,
			CONCAT(b.Nombres,' ',b.Apellidos) AS Nombres,
			a.Diagnostico,
			a.FechaIngreso,
			a.Estado
	FROM Atencion.HistorialMedico AS a, Atencion.Paciente AS b
	WHERE	a.IdPaciente = b.IdPaciente
	AND		a.Estado > 0 
	AND		a.IdPaciente = @_IdPaciente
	ORDER BY IdHistorialMedico
	
END

-- Prueba
EXEC Atencion.ObtenerHistorialesMedicosPaciente 1
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA OBTENER LOS HISTORIALES MEDICOS
ALTER PROC Atencion.ObtenerHistorialesMedicos
AS
BEGIN
	SELECT
			a.IdHistorialMedico,
			CONCAT(b.Nombres,' ',b.Apellidos) AS Nombres,
			a.Diagnostico,
			a.FechaIngreso,
			a.Estado
	FROM Atencion.HistorialMedico AS a
	LEFT JOIN Atencion.Paciente AS b
	ON b.IdPaciente = a.IdPaciente
	WHERE	a.Estado > 0
	
END

-- Prueba
EXEC Atencion.ObtenerHistorialesMedicos
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA OBTENER DATOS DE UN HISTORIAL MÉDICO
ALTER PROC Atencion.ObtenerDatosHistorialMedico	(	
													@_IdHistorialMedico INT
													)
AS
BEGIN
	SELECT
			IdHistorialMedico,
			IdPaciente,
			PesoLibras,
			AlturaCentimetros,
			PresionArterial,
			FrecuenciaCardiaca,
			FrecuenciaRespiratoria,
			TemperaturaCelsius,
			MotivoConsulta,
			Diagnostico,
			Tratamiento,
			Comentario
	FROM	Atencion.HistorialMedico AS a
	WHERE	a.IdHistorialMedico = @_IdHistorialMedico
END

-- Prueba
EXEC Atencion.ObtenerDatosHistorialMedico '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA ELIMINAR UN HISTORIAL MÉDICO (Cambiar de estado)
ALTER PROC Atencion.EliminarHistorialMedico	(
											@_IdHistorialMedico INT
											)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
BEGIN
	BEGIN TRAN
		BEGIN TRY	--ACTUALIZAR LA TABLA PARA CAMBIAR DE ESTADO
			UPDATE	Atencion.HistorialMedico
			SET		Estado = 0		
			WHERE	IdHistorialMedico = @_IdHistorialMedico

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado = @_IdHistorialMedico
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
EXEC Atencion.EliminarHistorialMedico '1'
--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 08/08/2022			*/

--PROCEDIMIENTO PARA MODIFICAR/ACTUALIZAR UN HISTORIAL MÉDICO
ALTER PROC Atencion.ModificarHistorialMedico	(
												@_IdHistorialMedico			INT,
												@_PesoLibras				DECIMAL(4, 1),
												@_AlturaCentimetros			INT,
												@_PresionArterial			NVARCHAR(10),
												@_FrecuenciaCardiaca		INT,
												@_FrecuenciaRespiratoria	INT,
												@_TemperaturaCelsius		DECIMAL(3,1),
												@_MotivoConsulta			NVARCHAR(MAX),
												@_Diagnostico				NVARCHAR(MAX),
												@_Tratamiento				NVARCHAR(MAX),
												@_Comentario				NVARCHAR(MAX)
												)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT

BEGIN
	BEGIN TRAN

	--IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	--IF(	@_PesoLibras = ''
	IF (@_AlturaCentimetros = ''
		OR @_PresionArterial = ''
		OR @_FrecuenciaCardiaca = ''
		OR @_FrecuenciaRespiratoria = ''
		--OR @_TemperaturaCelsius = ''
		OR @_MotivoConsulta = ''
		OR @_Diagnostico = ''
		OR @_Tratamiento = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END

	ELSE
		BEGIN TRY
			UPDATE	Atencion.HistorialMedico
			SET		
					PesoLibras				=	@_PesoLibras,
					AlturaCentimetros		=	@_AlturaCentimetros,
					PresionArterial			=	@_PresionArterial,
					FrecuenciaCardiaca		=	@_FrecuenciaCardiaca,
					FrecuenciaRespiratoria	=	@_FrecuenciaRespiratoria,
					TemperaturaCelsius		=	@_TemperaturaCelsius,
					MotivoConsulta			=	@_MotivoConsulta,
					Diagnostico				=	@_Diagnostico,
					Tratamiento				=	@_Tratamiento,
					Comentario				=	@_Comentario
			WHERE	IdHistorialMedico		=	@_IdHistorialMedico

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= @_IdHistorialMedico
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
EXEC Atencion.ModificarHistorialMedico '1', '158.5', '173', '120/80', '80', '20', '37.5', 'Fiebre de 6 días de evolución',
	'Amigdalitis Crónica', 'Ceftriaxona','Alérgica a los antibióticos'

------------------------------------ PROCEDIMIENTOS ALMACENADOS ESQUEMA COMPRA---------------------------------------------
/*================================================== TABLA PROVEEDORES ==================================================*/
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN PROVEEDOR
ALTER PROC Compra.AgregarProveedor (
											@_Nombres				NVARCHAR(50),
											@_Apellidos				NVARCHAR(50),
											@_Telefono				INT,
											@_LaboratorioClinico	NVARCHAR(100),
											@_Distribuidor			NVARCHAR(100),
											@_Token					NVARCHAR(250)
									  )	
AS
DECLARE @_FilasAfectadas				TINYINT,
		@_Resultado						SMALLINT,
		@_UltimoId						SMALLINT,
		@_IdUsuario						INT
		--@_NombreRepetido	NVARCHAR(100)
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdProveedor),0)
	FROM	Compra.Proveedor AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	= Sesion.ObtenerIdUsuario(@_Token)

	-- IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_Telefono = ''
		OR @_LaboratorioClinico = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END
	ELSE
		BEGIN TRY
				INSERT INTO Compra.Proveedor (
												IdProveedor,
												Nombres,
												Apellidos,
												Telefono,
												LaboratorioClinico,
												Distribuidor,
												IdUsuarioCreadoPor
											)
				VALUES						(
												@_UltimoId + 1,
												@_Nombres,
												@_Apellidos,
												@_Telefono,
												@_LaboratorioClinico,
												@_Distribuidor,
												@_IdUsuario
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

-- Prueba para Agregar Proveedor
EXEC Compra.AgregarProveedor 'Prueba','Prueba','12345678','PruebaPharma','','ikwbSNWMwfvvHKRHwpeQX8nwW5ksFub1TjePZyvlvN5mk03rXdVJqQiNGsN1QTYqJZ3PBdTmWdFaSGNYL9Q'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LOS PROVEEDORES
ALTER PROC Compra.ObtenerProveedores (
										@_Busqueda VARCHAR(100)=NULL
									  )
AS
BEGIN
	IF(@_Busqueda IS NULL)
	BEGIN
		SELECT
				a.IdProveedor,
				CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
				a.Telefono,
				a.LaboratorioClinico,
				a.Distribuidor,
				a.FechaIngreso,
				a.Estado

		FROM Compra.Proveedor AS a
		WHERE a.Estado > 0
		ORDER BY Nombres
	END

	ELSE
	BEGIN
		SELECT
				TOP 5
				a.IdProveedor,
				CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
				a.Telefono,
				a.LaboratorioClinico,
				a.Distribuidor,
				a.FechaIngreso,
				a.Estado

		FROM Compra.Proveedor a
		WHERE CONCAT(a.Nombres,' ',a.Apellidos) like CONCAT('%', @_Busqueda, '%')
		AND a.Estado > 0
		ORDER BY Nombres
	END
END

-- Prueba
EXEC Compra.ObtenerProveedores 'P'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA OBTENER SOLO 1 PACIENTE
ALTER PROC Compra.ObtenerUnProveedor	(	
											@_IdProveedor INT
										)
AS
BEGIN
	SELECT
			a.IdProveedor,
			CONCAT(a.Nombres,' ',a.Apellidos) AS Nombres,
			a.Telefono,
			a.LaboratorioClinico,
			a.Distribuidor

	FROM	Compra.Proveedor AS a
	WHERE	a.IdProveedor = @_IdProveedor

END

-- Prueba
EXEC Compra.ObtenerUnProveedor '5'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA OBTENER DATOS DE UN PROVEEDOR
ALTER PROC Compra.ObtenerDatosProveedor		(	
											@_IdProveedor INT
											)
AS
BEGIN
	SELECT
			a.IdProveedor,
			a.Nombres,
			a.Apellidos,
			a.Telefono,
			a.LaboratorioClinico,
			a.Distribuidor

	FROM	Compra.Proveedor AS a
	WHERE	a.IdProveedor = @_IdProveedor
END

-- Prueba
EXEC Compra.ObtenerDatosProveedor '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA ELIMINAR UN PROVEEDOR (Cambiar de estado)
ALTER PROC Compra.EliminarProveedor	(
										@_IdProveedor INT
									)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
BEGIN
	BEGIN TRAN
		BEGIN TRY	--ACTUALIZAR LA TABLA PARA CAMBIAR DE ESTADO
			UPDATE	Compra.Proveedor
			SET		Estado = 0		
			WHERE	IdProveedor = @_IdProveedor

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado = @_IdProveedor
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
EXEC Compra.EliminarProveedor '1'
--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA MODIFICAR/ACTUALIZAR UN PROVEEDOR
ALTER PROC Compra.ModificarProveedor	(
										@_IdProveedor			INT,
										@_Nombres				NVARCHAR(50),
										@_Apellidos				NVARCHAR(50),
										@_Telefono				INT,
										@_LaboratorioClinico	NVARCHAR(100),
										@_Distribuidor			NVARCHAR(100)
										)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
		--@_EmailRepetido		NVARCHAR(100)
BEGIN
	BEGIN TRAN

	-- IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_Telefono = ''
		OR @_LaboratorioClinico = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END
	ELSE
		BEGIN TRY
			UPDATE	Compra.Proveedor
			SET		
					Nombres					=	@_Nombres,
					Apellidos				=	@_Apellidos,
					Telefono				=	@_Telefono,
					LaboratorioClinico		=	@_LaboratorioClinico,
					Distribuidor			=	@_Distribuidor
			WHERE	IdProveedor = @_IdProveedor

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= @_IdProveedor
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
EXEC Compra.ModificarProveedor '1', 'Moisés','Pineda','58082946','Sued','Supharma'

/*================================================== TABLA CITA PROVEEDOR ==================================================*/
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA AGREGAR UNA CITA DE UN PROVEEDOR
ALTER PROC Compra.AgregarCitaProveedor		(
											@_IdProveedor				INT,
											@_Cita						DATE,
											@_Comentario				NVARCHAR(150),
											@_Token						NVARCHAR(250)
											)	
AS
DECLARE @_FilasAfectadas				TINYINT,
		@_Resultado						SMALLINT,
		@_UltimoId						SMALLINT,
		@_IdUsuario						INT
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdCitaProveedor),0)
	FROM	Compra.CitaProveedor AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	=	Sesion.ObtenerIdUsuario(@_Token)

	BEGIN TRY
			INSERT INTO Compra.CitaProveedor	(
													IdCitaProveedor,
													IdProveedor,
													Cita,
													Comentario,
													IdUsuarioCreadoPor
													)
			VALUES									(
													@_UltimoId + 1,
													@_IdProveedor,
													@_Cita,
													@_Comentario,
													@_IdUsuario
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

-- Prueba
EXEC Compra.AgregarCitaProveedor '1','21/09/2022','8 a.m. vendrá','ua3uZu1ke3xiyiEaWC7HtVays8wbdFbAEbDdJ1ueqtzNp9OeBOAjXqB9DLKBjAnDtB9JZYdfIXqWAEPlQp7w'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LAS CITAS DE UN PROVEEDOR
ALTER PROC Compra.ObtenerCitasProveedor (
											@_IdProveedor INT
										)
AS
BEGIN
	SELECT
			a.IdCitaProveedor,
			CONCAT(b.Nombres,' ',b.Apellidos) AS Nombres,
			b.LaboratorioClinico,
			a.Cita,
			a.Comentario,
			a.FechaIngreso,
			a.Estado
	FROM Compra.CitaProveedor AS a
	LEFT JOIN  Compra.Proveedor AS b
	ON b.IdProveedor = a.IdProveedor
	WHERE	a.Estado > 0 
	AND		a.IdProveedor = @_IdProveedor
	ORDER BY a.FechaIngreso
	
END

-- Prueba
EXEC Compra.ObtenerCitasProveedor 1
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LAS CITAS DE LOS PROVEEDORES
ALTER PROC Compra.ObtenerCitasProveedores
AS
BEGIN
	SELECT
			a.IdCitaProveedor,
			CONCAT(b.Nombres,' ',b.Apellidos) AS Nombres,
			b.LaboratorioClinico,
			a.Cita,
			a.Comentario,
			a.FechaIngreso,
			a.Estado
	FROM Compra.CitaProveedor AS a
	LEFT JOIN  Compra.Proveedor AS b
	ON b.IdProveedor = a.IdProveedor
	WHERE	a.Estado > 0 
	ORDER BY a.FechaIngreso
	
END

-- Prueba
EXEC Compra.ObtenerCitasProveedores
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA OBTENER DATOS DE UNA CITA DE UN PROVEEDOR
ALTER PROC Compra.ObtenerDatosCitaProveedor	(	
													@_IdCitaProveedor INT
												)
AS
BEGIN
	SELECT
			IdCitaProveedor,
			IdProveedor,
			Cita,
			Comentario
	FROM	Compra.CitaProveedor AS a
	WHERE	a.IdCitaProveedor = @_IdCitaProveedor
END

-- Prueba
EXEC Compra.ObtenerDatosCitaProveedor '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA ELIMINAR UNA CITA DE UN PROVEEDOR (Cambiar de estado)
ALTER PROC Compra.EliminarCitaProveedor	(
											@_IdCitaProveedor INT
											)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT
BEGIN
	BEGIN TRAN
		BEGIN TRY	--ACTUALIZAR LA TABLA PARA CAMBIAR DE ESTADO
			UPDATE	Compra.CitaProveedor
			SET		Estado = 0		
			WHERE	IdCitaProveedor = @_IdCitaProveedor

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado = @_IdCitaProveedor
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
EXEC Compra.EliminarCitaProveedor '1'
--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 06/09/2022			*/

--PROCEDIMIENTO PARA MODIFICAR/ACTUALIZAR UNA CITA DE UN PROVEEDOR
ALTER PROC Compra.ModificarCitaProveedor		(
												@_IdCitaProveedor			INT,
												@_Cita						DATE,
												@_Comentario				NVARCHAR(150)
												)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado		INT

BEGIN
	BEGIN TRAN

	 --IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(	@_Cita = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END

	ELSE
		BEGIN TRY
			UPDATE	Compra.CitaProveedor
			SET		
					Cita			=	@_Cita,
					Comentario		=	@_Comentario
			WHERE	IdCitaProveedor	=	@_IdCitaProveedor

			SET	@_FilasAfectadas = @@ROWCOUNT
		END TRY

		BEGIN CATCH
			SET	@_FilasAfectadas = 0
		END CATCH

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= @_IdCitaProveedor
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
EXEC Compra.ModificarCitaProveedor '1', '2022-09-22', '8 a.m. vendrá'

/*================================================== TABLA COMPRAS ==================================================*/
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA AGREGAR UNA COMPRA
ALTER PROC Compra.AgregarCompraProveedor	(
											@_NumFactura				NVARCHAR(20),
											@_IdProveedor				INT,
											@_FechaFactura				DATE,
											@_TotalCompra				DECIMAL(8,1),
											--@_IdEstadoCompra			TINYINT,
											@_Token						NVARCHAR(250)
											)	
AS
DECLARE @_FilasAfectadas				TINYINT,
		@_Resultado						SMALLINT,
		@_UltimoId						SMALLINT,
		@_IdUsuario						INT,
		@_FacturaExistente				NVARCHAR(20)
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdCompra),0)
	FROM	Compra.CompraProveedor AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	=	Sesion.ObtenerIdUsuario(@_Token)

	-- OBTENER CORREO SI YA EXISTE
	SELECT	@_FacturaExistente = NumFactura
	FROM	Compra.CompraProveedor
	WHERE	NumFactura = @_NumFactura

	--IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(	@_NumFactura		= ''
		OR @_FechaFactura	= '')
		--OR @_TotalCompra	= ''
		--OR @_TotalCompra	= 0
		--OR @_IdEstadoCompra = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END

	IF (@_NumFactura = @_FacturaExistente)
		BEGIN
			SELECT Alerta = 'La factura ya está registrada'
		END

	ELSE
		BEGIN TRY
				INSERT INTO Compra.CompraProveedor	(
														IdCompra,
														NumFactura,
														IdProveedor,
														FechaFactura,
														TotalCompra,
														--IdEstadoCompra,
														IdUsuarioCreadoPor
														)
				VALUES									(
														@_UltimoId + 1,
														@_NumFactura,
														@_IdProveedor,
														@_FechaFactura,
														@_TotalCompra,
														--@_IdEstadoCompra,
														@_IdUsuario
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

-- Prueba
EXEC Compra.AgregarCompraProveedor 'S6547SW','4','20/09/2022','5200','ZMsyS1GsDVW6zCrKCffgyQNO3UME7BcbPQIVVDEg4XVt9v57tJFHTIuZxJEJF9qxIFyRVZzC63v0TyepXpqQ'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LAS COMPRAS A UN PROVEEDOR
ALTER PROC Compra.ObtenerComprasProveedor (
											@_IdProveedor INT
											)
AS
BEGIN
	SELECT
			a.IdCompra,
			CONCAT(b.Nombres,' ',b.Apellidos) AS Nombres,
			CONCAT(b.LaboratorioClinico,' ',b.Distribuidor) AS Proveedor,
			a.NumFactura,
			a.FechaFactura,
			a.TotalCompra,
			c.Estado AS EstadoCompra,
			a.Estado
	FROM Compra.CompraProveedor AS a
	JOIN  Compra.Proveedor AS b
	ON b.IdProveedor = a.IdProveedor
	JOIN compra.EstadoCompraPago AS c
	ON c.IdEstadoCompra = a.IdEstadoCompra
	WHERE	a.Estado > 0 
	AND		a.IdProveedor = @_IdProveedor
	ORDER BY a.FechaIngreso
	
END

-- Prueba
EXEC Compra.ObtenerComprasProveedor 1
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LAS COMPRAS
ALTER PROC Compra.ObtenerComprasProveedores
AS
BEGIN
	SELECT
			a.IdCompra,
			CONCAT(b.Nombres,' ',b.Apellidos) AS Nombres,
			CONCAT(b.LaboratorioClinico,' ',b.Distribuidor) AS Proveedor,
			a.NumFactura,
			a.FechaFactura,
			a.TotalCompra,
			c.Estado AS EstadoCompra,
			a.Estado
	FROM Compra.CompraProveedor AS a
	JOIN  Compra.Proveedor AS b
	ON b.IdProveedor = a.IdProveedor
	JOIN compra.EstadoCompraPago AS c
	ON c.IdEstadoCompra = a.IdEstadoCompra
	WHERE	a.Estado > 0 
	ORDER BY a.FechaIngreso
	
END

-- Prueba
EXEC Compra.ObtenerComprasProveedores
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA OBTENER DATOS DE UNA COMPRA
ALTER PROC Compra.ObtenerDatosCompraProveedor	(	
													@_IdCompra INT
												)
AS
BEGIN
	SELECT
			a.IdCompra,
			a.NumFactura,
			a.FechaFactura,
			a.TotalCompra,
			a.IdEstadoCompra
	FROM	Compra.CompraProveedor AS a
	WHERE	a.IdCompra = @_IdCompra
END

-- Prueba
EXEC Compra.ObtenerDatosCompraProveedor '1'
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA ELIMINAR UNA COMPRA (Cambiar de estado)
ALTER PROC Compra.EliminarCompraProveedor	(
											@_IdCompra INT
											)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado			INT,
		@_EstadoCompra		TINYINT,
		@_MensajeTitulo		VARCHAR(100),
		@_Mensaje			VARCHAR(100)
BEGIN
	BEGIN TRAN
		--OBTENER ESTADO DE LA COMPRA
		SELECT @_EstadoCompra = IdEstadoCompra
		FROM Compra.CompraProveedor
		WHERE IdCompra = @_IdCompra
		
		--SI EL ESTADO DE LA COMPRA ES 1=NUEVO SE ELIMINA EL REGISTO (CAMBIAR ESTADO DE REGISTRO)
		IF(@_EstadoCompra = 1)
			BEGIN
				BEGIN TRY	--ACTUALIZAR LA TABLA PARA CAMBIAR DE ESTADO EL REGISTRO 0 = ELIMINADO
					UPDATE	Compra.CompraProveedor
					SET		Estado = 0		
					WHERE	IdCompra = @_IdCompra

					SET	@_FilasAfectadas = @@ROWCOUNT
					SET @_MensajeTitulo = '¡Compra eliminada exitósamente!'

				END TRY

				BEGIN CATCH
					SET	@_FilasAfectadas = 0
					SET @_Mensaje = 'Error al modificar estado del compra (EstadoC=1)'

				END CATCH
			END

		--SI EL ESTADO DE LA COMPRA ES 2=PENDIENTE NO SE ELIMINA EL REGISTRO, SE ANULA...,
		--SE CAMBIA EL ESTADO DE LA COMPRA A 4=ANULADO (PERO SIGUE APARECIENDO)
		ELSE IF(@_EstadoCompra = 2)
			BEGIN
				BEGIN TRY
					UPDATE	Compra.CompraProveedor
					SET		IdEstadoCompra	=	4
					WHERE	IdCompra = @_IdCompra

					SET	@_FilasAfectadas = @@ROWCOUNT
					
					--SELECT Alerta = 'Estado de Compra actualizado a Anulado'

					IF(@_FilasAfectadas > 0)
						BEGIN TRY
							--SE CAMBIA EL ESTADO DE TODOS LOS PAGOS REGISTRADOS A ESTA COMPRA A 4=ANULADO
							UPDATE	Compra.PagoAProveedor
							SET		IdEstadoPago = 4
							WHERE	IdCompra = @_IdCompra

							SET @_MensajeTitulo = '¡Compra y pagos anulados exitósamente!'
							SET @_Mensaje = 'No se eliminó la compra ya que posee pagos registrados'
							--SELECT	Alerta1 = 'Estado de Pagos actualizado a Anulado'
						END TRY

						BEGIN CATCH
							SET @_Mensaje = 'Error al modificar estado del pago'
							--SELECT Alerta = 'Error al modificar estado del pago'
						END CATCH

					ELSE
						BEGIN
							SET @_Mensaje = 'Error al modificar estado del compra'
							--SELECT Alerta2 = 'Error al modificar estado de la compra'
						END
				END TRY

				BEGIN CATCH
					SET	@_FilasAfectadas = 0
					SET @_Mensaje = 'Error al modificar estado del compra (EstadoC=2)'				
				END CATCH
			END
		
		--SI EL ESTADO DE LA COMPRA ES CANCELADO O ANULADO, NO PODRÁ ELIMINARSE EL REGISTRO
		ELSE IF(@_EstadoCompra = 3 OR @_EstadoCompra = 4)
			BEGIN
				SET @_Mensaje = 'La compra no puede eliminarse porque ya está cancelada o anulada'				
				--SELECT Alerta3 = 'La compra no puede eliminarse porque ya está cancelada o anulada'
			END

		IF(@_FilasAfectadas > 0)
			BEGIN
				SET @_Resultado = @_IdCompra
				COMMIT
			END
		ELSE
			BEGIN
				SET @_Resultado = 0
				ROLLBACK
			END

		SELECT	Resultado =	@_Resultado,
		MensajeTitulo = @_MensajeTitulo,
		Mensaje = @_Mensaje
END

-- Prueba
EXEC Compra.EliminarCompraProveedor '3'
--------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA MODIFICAR/ACTUALIZAR UNA COMPRA
ALTER PROC Compra.ModificarCompraProveedor		(
												@_IdCompra				INT,
												@_NumFactura			NVARCHAR(20),
												@_FechaFactura			DATE,
												@_TotalCompra			DECIMAL(8,1),
												@_IdEstadoCompra		TINYINT
												)
AS
DECLARE	@_FilasAfectadas	TINYINT,
		@_Resultado			INT,
		@_EstadoCompra		TINYINT,
		@_MensajeTitulo		VARCHAR(100),		
		@_Mensaje			VARCHAR(100)		
BEGIN
BEGIN TRAN
	--OBTENER ESTADO DE LA COMPRA
	SELECT @_EstadoCompra = IdEstadoCompra
	FROM Compra.CompraProveedor
	WHERE IdCompra = @_IdCompra

	 --IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(	@_NumFactura		= ''
		OR @_FechaFactura	= '')
		--OR @_TotalCompra	= ''
		--OR @_TotalCompra	= 0)
		BEGIN
			SET @_Mensaje = 'Existen campos vacíos'		
		END

	ELSE
		BEGIN
			-- SI EL ESTADO DE LA COMPRA ES 1=NUEVO PUEDE MODIFICARSE
			IF(@_EstadoCompra = 1)
				BEGIN
					BEGIN TRY
						UPDATE	Compra.CompraProveedor
						SET		
								NumFactura			=	@_NumFactura,
								FechaFactura		=	@_FechaFactura,
								TotalCompra			=	@_TotalCompra,
								IdEstadoCompra		=	@_IdEstadoCompra
						WHERE	IdCompra			=	@_IdCompra

						SET	@_FilasAfectadas = @@ROWCOUNT
						SET @_MensajeTitulo = '¡Compra modificada exitósamente!'

						--SI SE MODIFICA EL ESTADO DE LA COMPRA A 4=ANULADO
						IF(@_IdEstadoCompra = 4)
							BEGIN
								SET @_MensajeTitulo = '¡Compra modificada exitósamente!'				
								SET @_Mensaje = 'La compra fue anulada'
							END
					END TRY

					BEGIN CATCH
						SET	@_FilasAfectadas = 0
					END CATCH
				END

			-- SI EL ESTADO DE LA COMPRA ES 2=PENDIENTE PUEDE MODIFICARSE SOLO EL ESTADO
			ELSE IF (@_EstadoCompra = 2)
				BEGIN
					BEGIN TRY
						UPDATE	Compra.CompraProveedor
						SET		IdEstadoCompra	=	@_IdEstadoCompra
						WHERE	IdCompra = @_IdCompra

						SET	@_FilasAfectadas = @@ROWCOUNT
						SET @_MensajeTitulo = '¡Estado de compra modificado exitósamente!'
						SET @_Mensaje = 'El resto de campos no pueden modificarse porque existen pagos registrados'
						--SELECT Alerta = 'Estado de compra actualizado a Anulado'
					END TRY

					BEGIN CATCH
						SET	@_FilasAfectadas = 0
					END CATCH

					--SI SE MODIFICA EL ESTADO DE LA COMPRA A 4=ANULADO, CAMBIA EL ESTADO DE LOS PAGOS REGISTRADOS A ANULADO
					IF(@_IdEstadoCompra = 4)
						BEGIN
							UPDATE	Compra.PagoAProveedor
							SET		IdEstadoPago = 4
							WHERE	IdCompra = @_IdCompra

							SET @_MensajeTitulo = '¡Estado de compra y pagos anulados exitósamente!'
							SET @_Mensaje = 'El resto de campos no pueden modificarse porque existen pagos registrados'	
						END
				END

			--SI EL ESTADO DE LA COMPRA ES CANCELADO O ANULADO, NO PODRÁ MODIFICARSE
			ELSE
				BEGIN
					SET @_Mensaje = 'La compra no puede modificarse porque ya está cancelada o anulada'	
				END

		END

	IF(@_FilasAfectadas > 0)
		BEGIN
			SET @_Resultado	= @_IdCompra
			COMMIT
		END
	ELSE
		BEGIN
			SET @_Resultado	= 0
			ROLLBACK
		END

	SELECT	Resultado =	@_Resultado,
			MensajeTitulo = @_MensajeTitulo,
			Mensaje = @_Mensaje
END

-- Prueba
EXEC Compra.ModificarCompraProveedor '3','56413SW4','21/09/2022','3000','4'

/*================================================== TABLA PAGO A PROVEEDOR ==================================================*/
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA AGREGAR UN PAGO A UN PROVEEDOR (UNA COMPRA)
ALTER PROC Compra.AgregarPagoProveedor	(
											@_IdCompra					INT,
											@_FechaPago					DATE,
											@_MontoPago					DECIMAL(8,2),
											@_Token						NVARCHAR(250)
										)	
AS
DECLARE @_FilasAfectadas				TINYINT,
		@_Resultado						SMALLINT,
		@_UltimoId						SMALLINT,
		@_IdUsuario						INT,
		@_UltimaFechaPago				DATETIME,
		@_Saldo							DECIMAL(8,2) = 0,
		@_SaldoViejo					DECIMAL(8,2),
		@_EstadoCompra					TINYINT,
		@_EstadoPago					TINYINT,
		@_MensajeTitulo		VARCHAR(100),		
		@_Mensaje			VARCHAR(100)
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdPago),0)
	FROM	Compra.PagoAProveedor AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	=	Sesion.ObtenerIdUsuario(@_Token)

	--OBTENER ESTADO DE LA COMPRA
	SELECT @_EstadoCompra = IdEstadoCompra
	FROM Compra.CompraProveedor
	WHERE IdCompra = @_IdCompra

	--OBTENER ESTADO DEL PAGO
	SELECT @_EstadoPago = IdEstadoPago
	FROM Compra.PagoAProveedor
	WHERE IdCompra = @_IdCompra


	--IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(	@_FechaPago		= ''
		OR @_MontoPago	= 0)
		BEGIN
			SET @_Mensaje = 'Existen campos vacíos'	
		END

	ELSE
		BEGIN
			--SALDO PENDIENTE

			-- SE CONSULTA LA ÚLTIMA FECHA DE INGRESO
			SELECT @_UltimaFechaPago = MAX(FechaIngreso)
			FROM Compra.PagoAProveedor
			WHERE IdCompra = @_IdCompra
			--AND	IdEstadoPago = 5

			-- SE VERIFICA SI EXISTE O NO UN PAGO PARA CALCULAR EL SALDO
			-- SI EXISTE UN PAGO ANTERIOR AL NUEVO PAGO INGRESADO, SE CALCULA EL NUEVO SALDO EN BASE AL SALDO ANTERIOR
			IF(@_UltimaFechaPago IS NOT NULL)
				BEGIN
					SELECT	@_SaldoViejo = Saldo
					FROM	Compra.PagoAProveedor
					WHERE	IdCompra = @_IdCompra
					AND		FechaIngreso = @_UltimaFechaPago
				END
			
			-- SI NO EXISTE UN PAGO ANTERIOR, SE TOMA EL VALOR TOTAL DE LA FACTURA PARA CALCULARSE EL SALDO QUE QUEDARÁ
			ELSE
				BEGIN
					SELECT @_SaldoViejo = TotalCompra
					FROM Compra.CompraProveedor
					WHERE IdCompra = @_IdCompra
				END
			
			--SE PUEDE AGREGAR UN PAGO SI EL ESTADO DE LA COMPRA ES NUEVO O PENDIENTE
			IF(@_EstadoCompra = 1 OR @_EstadoCompra = 2)
				BEGIN
					-- VALIDACIÓN PARA EVITAR PAGAR MÁS DE LO QUE SE DEBE
					IF( @_MontoPago > @_SaldoViejo)
						BEGIN
							SET @_Mensaje = 'Error, monto excede saldo pendiente'	
						END

					-- CÁLCULO DEL SALDO PENDIENTE A PAGAR
					ELSE
						BEGIN
							SET @_Saldo = @_SaldoViejo - @_MontoPago

							BEGIN TRY
								INSERT INTO Compra.PagoAProveedor	(
																		IdPago,
																		IdCompra,
																		FechaPago,
																		MontoPago,
																		Saldo,
																		IdUsuarioCreadoPor
																		)
								VALUES									(
																		@_UltimoId + 1,
																		@_IdCompra,
																		@_FechaPago,
																		@_MontoPago,
																		@_Saldo,
																		@_IdUsuario
																		)
								SET @_FilasAfectadas = @@ROWCOUNT -- CUENTA LAS FILAS AFECTADAS
							END TRY

							BEGIN CATCH --SE SETEA EL VALOR DE 0 POR SI NO REALIZA LA TRANSACCIÓN
								SET @_FilasAfectadas = 0
							END CATCH
					
							-- SI SE AGREGA UN PAGO CAMBIAR ESTADO DE LA COMPRA A 2=PENDIENTE
							IF(@_EstadoCompra = 1)
								BEGIN
									UPDATE	Compra.CompraProveedor
									SET		IdEstadoCompra		=	2
									WHERE	IdCompra			=	@_IdCompra

									SET @_Mensaje = 'Estado de compra actualizado a pendiente'
								END
						
							-- SI EL SALDO PENDIENTE LLEGA A 0, CAMBIAR EL ESTADO DE LA COMPRA A 3=CANCELADA
							IF(@_Saldo = 0)
								BEGIN
									UPDATE	Compra.CompraProveedor
									SET		IdEstadoCompra		=	3
									WHERE	IdCompra			=	@_IdCompra

									SET @_Mensaje = 'Saldo de la compra cancelado totalmente'
								END
						END
				END

			--SI EL ESTADO DE LA COMPRA ES CANCELADO O ANULADO, NO SE PODRÁ AGREGAR OTRO PAGO
			ELSE
				BEGIN
							SET @_Mensaje = 'No se puede agregar otro pago porque la compra ya está cancelada o anulada'
				END
		END

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
		SELECT Resultado = @_Resultado,
		MensajeTitulo = @_MensajeTitulo,
		Mensaje = @_Mensaje
END --FIN 

-- Prueba
EXEC Compra.AgregarPagoProveedor '1','22/10/2022','1000','9YCCxel1kST5W5zXxuoVDqxv4Z1lJdxaHvKCLnDk9jMIG8EdJpwotaACIFgXzuMN6eRO0cyUNzg5BkCudF6w'

EXEC Compra.ObtenerComprasProveedores
EXEC Compra.ObtenerPagosProveedor 1

---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LOS PAGOS A UN PROVEEDOR DE UNA COMPRA
ALTER PROC Compra.ObtenerPagosProveedor (
											@_IdCompra INT
										 )
AS
BEGIN
	SELECT	
			a.IdPago,
			b.NumFactura,
			b.TotalCompra,
			a.FechaPago,
			a.MontoPago,
			a.Saldo,
			c.Estado AS EstadoPago
	FROM Compra.PagoAProveedor AS a
	JOIN  Compra.CompraProveedor AS b
	ON b.IdCompra = a.IdCompra
	JOIN compra.EstadoCompraPago AS c
	ON c.IdEstadoCompra = a.IdEstadoPago
	WHERE	a.IdCompra = @_IdCompra
	ORDER BY a.FechaIngreso
	
END

-- Prueba
EXEC Compra.ObtenerPagosProveedor 3
---------------------------------------------------------------------------------------------------------------------
/*		AUTOR: Daniel Juárez	
		FECHA: 27/09/2022			*/

--PROCEDIMIENTO PARA OBTENER LAS COMPRAS A LOS PROVEEDOR
ALTER PROC Compra.ObtenerPagosProveedores
AS
BEGIN
	SELECT		
			a.IdPago,
			b.NumFactura,
			b.TotalCompra,
			a.FechaPago,
			a.MontoPago,
			a.Saldo,
			c.Estado AS EstadoPago
	FROM Compra.PagoAProveedor AS a
	JOIN  Compra.CompraProveedor AS b
	ON b.IdCompra = a.IdCompra
	JOIN compra.EstadoCompraPago AS c
	ON c.IdEstadoCompra = a.IdEstadoPago
	--WHERE	a.IdCompra = @_IdCompra
	ORDER BY a.FechaIngreso

END

-- Prueba
EXEC Compra.ObtenerPagosProveedores