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
ALTER SCHEMA Compra TRANSFER dbo.PagoAProveedor

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
			a.FechaIngreso,
			a.Estado

	FROM Sesion.Usuario AS a
--	LEFT JOIN Sesion.Rol AS b
--	ON b.IdRol = a.IdRol
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

	SELECT	@_EmailRepetido = Email
	FROM	Sesion.Usuario
	WHERE	Email = @_Email

	--IF (@_Email = @_EmailRepetido)
		--BEGIN
	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_Direccion = ''
		OR @_Email = ''
		--OR @_Contrasenia = ''
		OR @_IdRol = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos o el correo ya está registrado'
		END
		--END
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
		--@_NombreRepetido	NVARCHAR(100)
BEGIN
BEGIN TRAN
	--OBTENER EL ULTIMO ID GUARDADO EN LA TABLA
	SELECT	@_UltimoId = ISNULL(MAX(a.IdPaciente),0)
	FROM	Atencion.Paciente AS a

	--SE OBTIENE EL ID DEL USUARIO
	SELECT	@_IdUsuario	=	Sesion.ObtenerIdUsuario(@_Token)

	---- OBTENER NOMBRE SI YA EXISTE
	--SELECT	@_NombreRepetido = CONCAT(a.Nombres,' ',a.Apellidos)	AS	Nombres
	--FROM	Atencion.Paciente as a
	--WHERE	Nombres = @_Email

	--IF (@_Email = @_EmailRepetido)
	--	BEGIN
	--		SELECT Alerta = 'El paciente ya está registrado'
	--	END
	--ELSE	-- SI EL CORREO NO EXISTE, REALIZA EL INSERT

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
EXEC Atencion.AgregarPaciente 'Prueba','Prueba','01/05/1999','Poptún','M','11223344','xAyGm3ompCWPaYGVWGzFElPg3MmHFbZdKx21cg4FJLhL0vD89U7XeWlRIUhHR5b8LLDUMbKIKM8xKumjduA'
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
EXEC Atencion.ObtenerPacientes 'r'
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
			--CONVERT(varchar(10),a.FechaNacimiento,103),
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

	--SELECT	@_EmailRepetido = Email
	--FROM	Sesion.Usuario
	--WHERE	Email = @_Email

	--IF (@_Email = @_EmailRepetido)
		--BEGIN
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
		--END
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

	-- IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	--IF(	@_PesoLibras = ''
	--	OR @_AlturaCentimetros = ''
	--	OR @_PresionArterial = ''
	--	OR @_FrecuenciaCardiaca = ''
	--	OR @_FrecuenciaRespiratoria = ''
	--	OR @_TemperaturaCelsius = ''
	--	OR @_MotivoConsulta = ''
	--	OR @_Diagnostico = ''
	--	OR @_Tratamiento = ''
	--	OR @_Comentario = '')
	--	BEGIN
	--		SELECT Alerta = 'Campos vacíos'
	--	END
	--	--END
	--ELSE
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
