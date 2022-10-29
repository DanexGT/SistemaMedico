USE [BDSistemaMedico]
GO
/****** Object:  Schema [Atencion]    Script Date: 29/10/2022 10:46:46 ******/
CREATE SCHEMA [Atencion]
GO
/****** Object:  Schema [Compra]    Script Date: 29/10/2022 10:46:46 ******/
CREATE SCHEMA [Compra]
GO
/****** Object:  Schema [Sesion]    Script Date: 29/10/2022 10:46:46 ******/
CREATE SCHEMA [Sesion]
GO
/****** Object:  UserDefinedFunction [Sesion].[ObtenerIdUsuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Sesion].[ObtenerIdUsuario](
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
GO
/****** Object:  UserDefinedFunction [Sesion].[VerificarVigenciaToken]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Sesion].[VerificarVigenciaToken]	(
													@_Token		NVARCHAR(250)
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
GO
/****** Object:  Table [Atencion].[HistorialMedico]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Atencion].[HistorialMedico](
	[IdHistorialMedico] [int] NOT NULL,
	[IdPaciente] [int] NOT NULL,
	[PesoLibras] [decimal](4, 1) NOT NULL,
	[AlturaCentimetros] [int] NOT NULL,
	[PresionArterial] [varchar](10) NOT NULL,
	[FrecuenciaCardiaca] [int] NOT NULL,
	[FrecuenciaRespiratoria] [int] NOT NULL,
	[TemperaturaCelsius] [decimal](3, 1) NOT NULL,
	[MotivoConsulta] [varchar](max) NOT NULL,
	[Diagnostico] [varchar](max) NOT NULL,
	[Tratamiento] [varchar](max) NOT NULL,
	[Comentario] [varchar](max) NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_HistorialMedico] PRIMARY KEY CLUSTERED 
(
	[IdHistorialMedico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Atencion].[Paciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Atencion].[Paciente](
	[IdPaciente] [int] NOT NULL,
	[Nombres] [varchar](50) NOT NULL,
	[Apellidos] [varchar](50) NOT NULL,
	[FechaNacimiento] [date] NOT NULL,
	[Direccion] [varchar](max) NOT NULL,
	[Sexo] [varchar](1) NOT NULL,
	[Telefono] [int] NOT NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_Paciente] PRIMARY KEY CLUSTERED 
(
	[IdPaciente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Compra].[CitaProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compra].[CitaProveedor](
	[IdCitaProveedor] [int] NOT NULL,
	[IdProveedor] [int] NOT NULL,
	[Cita] [date] NOT NULL,
	[Comentario] [varchar](150) NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_CitaProveedor] PRIMARY KEY CLUSTERED 
(
	[IdCitaProveedor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Compra].[CompraProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compra].[CompraProveedor](
	[IdCompra] [int] NOT NULL,
	[NumFactura] [varchar](20) NOT NULL,
	[IdProveedor] [int] NOT NULL,
	[FechaFactura] [date] NOT NULL,
	[TotalCompra] [decimal](8, 2) NOT NULL,
	[IdEstadoCompra] [tinyint] NOT NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_PagoAProveedor] PRIMARY KEY CLUSTERED 
(
	[IdCompra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Compra].[EstadoCompraPago]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compra].[EstadoCompraPago](
	[IdEstadoCompra] [tinyint] NOT NULL,
	[Estado] [varchar](15) NOT NULL,
 CONSTRAINT [PK_EstadoCompra] PRIMARY KEY CLUSTERED 
(
	[IdEstadoCompra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Compra].[PagoAProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compra].[PagoAProveedor](
	[IdPago] [int] NOT NULL,
	[IdCompra] [int] NOT NULL,
	[FechaPago] [date] NOT NULL,
	[MontoPago] [decimal](8, 2) NOT NULL,
	[Saldo] [decimal](8, 2) NOT NULL,
	[IdEstadoPago] [tinyint] NOT NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
 CONSTRAINT [PK_Pago] PRIMARY KEY CLUSTERED 
(
	[IdPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Compra].[Proveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Compra].[Proveedor](
	[IdProveedor] [int] NOT NULL,
	[Nombres] [varchar](50) NOT NULL,
	[Apellidos] [varchar](50) NOT NULL,
	[Telefono] [int] NOT NULL,
	[LaboratorioClinico] [varchar](100) NOT NULL,
	[Distribuidor] [varchar](100) NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED 
(
	[IdProveedor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Sesion].[Menu]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sesion].[Menu](
	[IdMenu] [int] NOT NULL,
	[IdModulo] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
	[URL] [varchar](250) NOT NULL,
	[TextoIcono] [varchar](250) NOT NULL,
	[IdMenuPadre] [int] NOT NULL,
	[Estado] [tinyint] NOT NULL,
	[OrdenMenu] [decimal](4, 2) NOT NULL,
 CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED 
(
	[IdMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Sesion].[MenuPorRol]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sesion].[MenuPorRol](
	[IdMenuPorRol] [int] NOT NULL,
	[IdRol] [int] NOT NULL,
	[IdMenu] [int] NOT NULL,
	[Agregar] [bit] NOT NULL,
	[Modificar] [bit] NOT NULL,
	[Eliminar] [bit] NOT NULL,
	[Consultar] [bit] NOT NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_MenuPorRol] PRIMARY KEY CLUSTERED 
(
	[IdMenuPorRol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Sesion].[Modulo]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sesion].[Modulo](
	[IdModulo] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
	[TextoIcono] [varchar](250) NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_Modulo] PRIMARY KEY CLUSTERED 
(
	[IdModulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Sesion].[Rol]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sesion].[Rol](
	[IdRol] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_Rol] PRIMARY KEY CLUSTERED 
(
	[IdRol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Sesion].[Token]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sesion].[Token](
	[IdToken] [int] NOT NULL,
	[Token] [varchar](250) NOT NULL,
	[VigenciaMinutos] [int] NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
 CONSTRAINT [PK_Token] PRIMARY KEY CLUSTERED 
(
	[IdToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Sesion].[Usuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Sesion].[Usuario](
	[IdUsuario] [int] NOT NULL,
	[Nombres] [varchar](50) NOT NULL,
	[Apellidos] [varchar](50) NOT NULL,
	[Direccion] [varchar](max) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[Contrasenia] [varchar](max) NOT NULL,
	[IdUsuarioCreadoPor] [int] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	[Estado] [tinyint] NOT NULL,
	[IdRol] [int] NOT NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[IdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT [Atencion].[HistorialMedico] ([IdHistorialMedico], [IdPaciente], [PesoLibras], [AlturaCentimetros], [PresionArterial], [FrecuenciaCardiaca], [FrecuenciaRespiratoria], [TemperaturaCelsius], [MotivoConsulta], [Diagnostico], [Tratamiento], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (1, 1, CAST(122.0 AS Decimal(4, 1)), 155, N'121/79', 77, 19, CAST(37.0 AS Decimal(3, 1)), N'Fiebre de 6 días de evolución', N'Amigdalitis Crónica', N'- Cefixima 400mg
- Bronco Cort', N'Alérgica a los antibióticos', 2, CAST(N'2022-08-13T15:01:46.820' AS DateTime), 1)
GO
INSERT [Atencion].[HistorialMedico] ([IdHistorialMedico], [IdPaciente], [PesoLibras], [AlturaCentimetros], [PresionArterial], [FrecuenciaCardiaca], [FrecuenciaRespiratoria], [TemperaturaCelsius], [MotivoConsulta], [Diagnostico], [Tratamiento], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (2, 2, CAST(160.5 AS Decimal(4, 1)), 173, N'120/80', 80, 20, CAST(38.5 AS Decimal(3, 1)), N'Fiebre de 6 días de evolución', N'Amigdalitis Crónica', N'Ceftriaxona', N'Trabaja en ganadería', 2, CAST(N'2022-08-13T15:54:54.133' AS DateTime), 1)
GO
INSERT [Atencion].[HistorialMedico] ([IdHistorialMedico], [IdPaciente], [PesoLibras], [AlturaCentimetros], [PresionArterial], [FrecuenciaCardiaca], [FrecuenciaRespiratoria], [TemperaturaCelsius], [MotivoConsulta], [Diagnostico], [Tratamiento], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (3, 1, CAST(120.0 AS Decimal(4, 1)), 155, N'125/90', 75, 17, CAST(37.5 AS Decimal(3, 1)), N'Dolor de cabeza', N'Faringitis estreptocócica', N'-Ibuprofeno 
-Acetaminofén', N'Padece seguido de infección de garganta', 2, CAST(N'2022-08-14T16:56:22.427' AS DateTime), 1)
GO
INSERT [Atencion].[HistorialMedico] ([IdHistorialMedico], [IdPaciente], [PesoLibras], [AlturaCentimetros], [PresionArterial], [FrecuenciaCardiaca], [FrecuenciaRespiratoria], [TemperaturaCelsius], [MotivoConsulta], [Diagnostico], [Tratamiento], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (4, 2, CAST(160.0 AS Decimal(4, 1)), 173, N'120/80', 80, 20, CAST(37.5 AS Decimal(3, 1)), N'Dolor de cabeza y naúseas', N'Cefalea y naúseas', N'- Acetaminofen
- Ibuprofeno', N'Pasa mucho tiempo bajo el sol', 1, CAST(N'2022-08-15T23:31:42.260' AS DateTime), 1)
GO
INSERT [Atencion].[Paciente] ([IdPaciente], [Nombres], [Apellidos], [FechaNacimiento], [Direccion], [Sexo], [Telefono], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (1, N'Meredith', N'Reyes', CAST(N'2002-04-15' AS Date), N'Poptún', N'F', 53009548, 1, CAST(N'2022-08-13T09:59:42.050' AS DateTime), 1)
GO
INSERT [Atencion].[Paciente] ([IdPaciente], [Nombres], [Apellidos], [FechaNacimiento], [Direccion], [Sexo], [Telefono], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (2, N'Carlos', N'Mayén', CAST(N'2019-05-10' AS Date), N'Poptún', N'M', 42104003, 2, CAST(N'2022-08-13T10:43:50.710' AS DateTime), 1)
GO
INSERT [Atencion].[Paciente] ([IdPaciente], [Nombres], [Apellidos], [FechaNacimiento], [Direccion], [Sexo], [Telefono], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (3, N'Yovani', N'Polanco', CAST(N'1967-11-14' AS Date), N'Poptún', N'M', 41088105, 1, CAST(N'2022-08-15T08:45:35.880' AS DateTime), 1)
GO
INSERT [Atencion].[Paciente] ([IdPaciente], [Nombres], [Apellidos], [FechaNacimiento], [Direccion], [Sexo], [Telefono], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (4, N'Miguel', N'Góngora', CAST(N'1996-09-15' AS Date), N'San Benito', N'M', 40137516, 1, CAST(N'2022-09-16T09:48:47.577' AS DateTime), 1)
GO
INSERT [Atencion].[Paciente] ([IdPaciente], [Nombres], [Apellidos], [FechaNacimiento], [Direccion], [Sexo], [Telefono], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (5, N'Bryan', N'Quintanilla', CAST(N'2007-03-06' AS Date), N'Poptún', N'M', 12345678, 1, CAST(N'2022-10-27T10:27:30.447' AS DateTime), 1)
GO
INSERT [Atencion].[Paciente] ([IdPaciente], [Nombres], [Apellidos], [FechaNacimiento], [Direccion], [Sexo], [Telefono], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (6, N'Boris', N'Juárez', CAST(N'1967-11-14' AS Date), N'Poptún', N'M', 1234578, 1, CAST(N'2022-10-28T17:11:50.053' AS DateTime), 0)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (1, 1, CAST(N'2022-09-22' AS Date), N'9 a.m. vendrá', 1, CAST(N'2022-09-20T22:30:38.897' AS DateTime), 1)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (2, 2, CAST(N'2022-09-23' AS Date), N'', 1, CAST(N'2022-09-20T22:31:29.587' AS DateTime), 0)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (3, 5, CAST(N'2022-09-26' AS Date), N'Pendiente devolver Q10', 1, CAST(N'2022-09-20T22:32:43.770' AS DateTime), 1)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (4, 1, CAST(N'2022-10-11' AS Date), N'', 1, CAST(N'2022-09-20T22:38:42.127' AS DateTime), 0)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (5, 2, CAST(N'2022-10-18' AS Date), N'', 1, CAST(N'2022-09-20T23:25:35.263' AS DateTime), 1)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (6, 1, CAST(N'2022-10-25' AS Date), N'Abono pendiente', 1, CAST(N'2022-10-11T18:16:18.833' AS DateTime), 1)
GO
INSERT [Compra].[CitaProveedor] ([IdCitaProveedor], [IdProveedor], [Cita], [Comentario], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (7, 7, CAST(N'2022-11-15' AS Date), N'', 1, CAST(N'2022-10-11T18:51:04.967' AS DateTime), 1)
GO
INSERT [Compra].[CompraProveedor] ([IdCompra], [NumFactura], [IdProveedor], [FechaFactura], [TotalCompra], [IdEstadoCompra], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (1, N'75D48F7', 1, CAST(N'2022-09-20' AS Date), CAST(3500.00 AS Decimal(8, 2)), 4, 1, CAST(N'2022-10-19T22:50:32.380' AS DateTime), 1)
GO
INSERT [Compra].[CompraProveedor] ([IdCompra], [NumFactura], [IdProveedor], [FechaFactura], [TotalCompra], [IdEstadoCompra], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (2, N'S6547SW', 4, CAST(N'2022-09-20' AS Date), CAST(5200.00 AS Decimal(8, 2)), 3, 1, CAST(N'2022-10-20T01:29:05.137' AS DateTime), 1)
GO
INSERT [Compra].[CompraProveedor] ([IdCompra], [NumFactura], [IdProveedor], [FechaFactura], [TotalCompra], [IdEstadoCompra], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (3, N'56413SW4', 2, CAST(N'2022-10-21' AS Date), CAST(2000.00 AS Decimal(8, 2)), 2, 1, CAST(N'2022-10-21T01:09:01.673' AS DateTime), 1)
GO
INSERT [Compra].[CompraProveedor] ([IdCompra], [NumFactura], [IdProveedor], [FechaFactura], [TotalCompra], [IdEstadoCompra], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (4, N'314HUW1', 8, CAST(N'2022-10-23' AS Date), CAST(3252.00 AS Decimal(8, 2)), 1, 1, CAST(N'2022-10-24T13:56:35.457' AS DateTime), 1)
GO
INSERT [Compra].[EstadoCompraPago] ([IdEstadoCompra], [Estado]) VALUES (1, N'Nuevo')
GO
INSERT [Compra].[EstadoCompraPago] ([IdEstadoCompra], [Estado]) VALUES (2, N'Pendiente')
GO
INSERT [Compra].[EstadoCompraPago] ([IdEstadoCompra], [Estado]) VALUES (3, N'Cancelado')
GO
INSERT [Compra].[EstadoCompraPago] ([IdEstadoCompra], [Estado]) VALUES (4, N'Anulado')
GO
INSERT [Compra].[EstadoCompraPago] ([IdEstadoCompra], [Estado]) VALUES (5, N'Confirmado')
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (1, 1, CAST(N'2022-10-15' AS Date), CAST(1000.00 AS Decimal(8, 2)), CAST(2500.00 AS Decimal(8, 2)), 4, 1, CAST(N'2022-10-20T00:43:33.703' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (2, 1, CAST(N'2022-10-17' AS Date), CAST(500.00 AS Decimal(8, 2)), CAST(2000.00 AS Decimal(8, 2)), 4, 1, CAST(N'2022-10-20T00:54:36.520' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (3, 1, CAST(N'2022-10-20' AS Date), CAST(500.00 AS Decimal(8, 2)), CAST(1500.00 AS Decimal(8, 2)), 4, 1, CAST(N'2022-10-20T01:23:54.933' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (4, 2, CAST(N'2022-10-01' AS Date), CAST(500.00 AS Decimal(8, 2)), CAST(4700.00 AS Decimal(8, 2)), 5, 1, CAST(N'2022-10-20T01:39:27.720' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (5, 2, CAST(N'2022-10-07' AS Date), CAST(1235.00 AS Decimal(8, 2)), CAST(3465.00 AS Decimal(8, 2)), 5, 1, CAST(N'2022-10-20T01:40:28.580' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (6, 2, CAST(N'2022-10-12' AS Date), CAST(3000.00 AS Decimal(8, 2)), CAST(465.00 AS Decimal(8, 2)), 5, 1, CAST(N'2022-10-20T01:53:38.587' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (7, 2, CAST(N'2022-10-19' AS Date), CAST(465.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 5, 1, CAST(N'2022-10-20T20:13:14.317' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (8, 3, CAST(N'2022-10-20' AS Date), CAST(1000.00 AS Decimal(8, 2)), CAST(1000.00 AS Decimal(8, 2)), 5, 1, CAST(N'2022-10-21T18:44:48.213' AS DateTime))
GO
INSERT [Compra].[PagoAProveedor] ([IdPago], [IdCompra], [FechaPago], [MontoPago], [Saldo], [IdEstadoPago], [IdUsuarioCreadoPor], [FechaIngreso]) VALUES (9, 3, CAST(N'2022-10-21' AS Date), CAST(500.50 AS Decimal(8, 2)), CAST(499.50 AS Decimal(8, 2)), 5, 1, CAST(N'2022-10-21T22:49:22.610' AS DateTime))
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (1, N'Moisés', N'Pineda', 58082946, N'Sued', N'Supharma', 1, CAST(N'2022-09-19T12:55:51.830' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (2, N'Marco', N'Recinos', 50509212, N'Vitabiotics', N'Coide', 1, CAST(N'2022-09-20T20:29:12.943' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (3, N'Elba', N'Gamboa', 41365438, N'Moba', N'', 1, CAST(N'2022-09-20T20:30:04.020' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (4, N'Gabriel', N'Celada', 55147184, N'Laxmi', N'', 1, CAST(N'2022-09-20T20:30:48.090' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (5, N'Leslie', N'Martínez', 56362875, N'Abbott', N'Lanquetin', 1, CAST(N'2022-09-20T20:32:37.073' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (6, N'Josué', N'Aquino', 45135009, N'Laboxpharma', N'', 1, CAST(N'2022-09-20T21:17:41.940' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (7, N'Bernardo', N'López', 53060066, N'Sanfer/Bussié', N'Becofarma/Befasa', 1, CAST(N'2022-10-11T18:50:29.130' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (8, N'Nora', N'Córdova', 56167554, N'MedPharm', N'Resco', 1, CAST(N'2022-10-20T12:26:47.727' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (9, N'Luis', N'Beltrán', 40811391, N'Asielsa', N'', 1, CAST(N'2022-10-27T10:42:32.067' AS DateTime), 1)
GO
INSERT [Compra].[Proveedor] ([IdProveedor], [Nombres], [Apellidos], [Telefono], [LaboratorioClinico], [Distribuidor], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (10, N'Gabriel', N'Aldana', 48865575, N'Piersan', N'Pharmacorp', 1, CAST(N'2022-10-28T11:05:28.340' AS DateTime), 1)
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (1, 1, N'Usuarios', N'Menú para gestionar la información de los usuarios', N'/usuarios.html', N'fa-solid fa-user-plus', 1, 1, CAST(1.00 AS Decimal(4, 2)))
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (2, 2, N'Pacientes', N'Menú para gestionar la información de los pacientes', N'/pacientes.html', N'fas fa-user-injured', 2, 1, CAST(2.00 AS Decimal(4, 2)))
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (3, 3, N'Historial Médico', N'Módulo para gestionar las fichas médicas de cada paciente', N'/historialmedico.html', N'fa-solid fa-file-medical', 3, 1, CAST(3.00 AS Decimal(4, 2)))
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (4, 4, N'Proveedores', N'Menú para gestionar la información y citas de los proveedores (visitadores médicos)', N'#', N'fa-solid fa-user-tie', 4, 1, CAST(4.00 AS Decimal(4, 2)))
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (5, 4, N'Registros', N'Menú para gestionar la información de los proveedores', N'/proveedores.html', N'fa-solid fa-file-pen', 4, 1, CAST(4.10 AS Decimal(4, 2)))
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (6, 4, N'Citas', N'Menú para gestionar las citas de los proveedores (visitadores médicos)', N'/citasproveedores.html', N'fa-solid fa-calendar-check', 4, 1, CAST(4.20 AS Decimal(4, 2)))
GO
INSERT [Sesion].[Menu] ([IdMenu], [IdModulo], [Nombre], [Descripcion], [URL], [TextoIcono], [IdMenuPadre], [Estado], [OrdenMenu]) VALUES (7, 5, N'Compras y Pagos', N'Menú para gestionar los pagos a los proveedores (visitadores médicos)', N'/compras-pagos-proveedores.html', N'fa-solid fa-money-bill-1-wave', 7, 1, CAST(5.00 AS Decimal(4, 2)))
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (1, 1, 1, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:00:42.280' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (2, 1, 2, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:01:24.780' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (3, 1, 3, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:01:34.203' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (4, 1, 5, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:02:08.270' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (5, 1, 6, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:03:29.180' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (6, 1, 7, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:03:44.163' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (7, 2, 2, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:06:00.733' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (8, 2, 3, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:06:15.280' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (9, 2, 5, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:06:33.327' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (10, 2, 6, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:06:45.880' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (11, 2, 7, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:07:00.900' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (12, 3, 2, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:15:10.683' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (13, 3, 3, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:16:15.070' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (14, 3, 5, 0, 0, 0, 1, 1, CAST(N'2022-07-31T02:20:31.157' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (15, 3, 6, 0, 0, 0, 1, 1, CAST(N'2022-07-31T02:22:41.713' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (16, 3, 7, 0, 0, 0, 1, 1, CAST(N'2022-07-31T02:22:54.337' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (17, 4, 2, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:34:09.020' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (18, 4, 3, 0, 0, 0, 1, 1, CAST(N'2022-07-31T02:34:46.990' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (19, 4, 5, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:35:05.403' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (20, 4, 6, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:35:12.847' AS DateTime), 1)
GO
INSERT [Sesion].[MenuPorRol] ([IdMenuPorRol], [IdRol], [IdMenu], [Agregar], [Modificar], [Eliminar], [Consultar], [IdUsuarioCreadoPor], [FechaIngreso], [Estado]) VALUES (21, 4, 7, 1, 1, 1, 1, 1, CAST(N'2022-07-31T02:35:22.010' AS DateTime), 1)
GO
INSERT [Sesion].[Modulo] ([IdModulo], [Nombre], [Descripcion], [TextoIcono], [Estado]) VALUES (1, N'Usuarios', N'Módulo para gestionar los usuarios que usarán el sistema', NULL, 1)
GO
INSERT [Sesion].[Modulo] ([IdModulo], [Nombre], [Descripcion], [TextoIcono], [Estado]) VALUES (2, N'Pacientes', N'Módulo para gestionar los pacientes que entren a consulta', NULL, 1)
GO
INSERT [Sesion].[Modulo] ([IdModulo], [Nombre], [Descripcion], [TextoIcono], [Estado]) VALUES (3, N'Historial Médico', N'Módulo para gestionar las fichas médicas de cada paciente', NULL, 1)
GO
INSERT [Sesion].[Modulo] ([IdModulo], [Nombre], [Descripcion], [TextoIcono], [Estado]) VALUES (4, N'Proveedores', N'Módulo para gestionar la información y citas de los proveedores (visitadores médicos)', NULL, 1)
GO
INSERT [Sesion].[Modulo] ([IdModulo], [Nombre], [Descripcion], [TextoIcono], [Estado]) VALUES (5, N'Compras y Pagos', N'Módulo para gestionar los pagos a proveedores (pendientes y cancelados)', NULL, 1)
GO
INSERT [Sesion].[Rol] ([IdRol], [Nombre], [Descripcion], [IdUsuario], [FechaIngreso], [Estado]) VALUES (1, N'Administrador', N'Permisos absolutos del sistema y funciones', 1, CAST(N'2022-07-30T12:23:13.943' AS DateTime), 1)
GO
INSERT [Sesion].[Rol] ([IdRol], [Nombre], [Descripcion], [IdUsuario], [FechaIngreso], [Estado]) VALUES (2, N'Doctor', N'Acceso a todos los módulos, menús y funciones. No acceso a módulo Usuarios', 1, CAST(N'2022-07-31T01:52:41.307' AS DateTime), 1)
GO
INSERT [Sesion].[Rol] ([IdRol], [Nombre], [Descripcion], [IdUsuario], [FechaIngreso], [Estado]) VALUES (3, N'Enfermero', N'Acceso a todos los módulos y menús. Solo lectura en módulos Proveedores y Pagos. No acceso a módulo Usuarios', 1, CAST(N'2022-07-31T01:56:27.240' AS DateTime), 1)
GO
INSERT [Sesion].[Rol] ([IdRol], [Nombre], [Descripcion], [IdUsuario], [FechaIngreso], [Estado]) VALUES (4, N'Asistente', N'Acceso a todos los módulos y menús. Solo lectura en módulo Historial Médico. No acceso a módulo Usuarios', 1, CAST(N'2022-07-31T01:59:30.027' AS DateTime), 1)
GO
INSERT [Sesion].[Token] ([IdToken], [Token], [VigenciaMinutos], [IdUsuario], [FechaIngreso], [Estado]) VALUES (127, N's4x8ZTbeg3kCT0dsVMAfsteaa57VOyJMcH0RjDtFzKtKuhAaifgdPlHSGFwypFc3VajjfYM7zWf5V684nN7g', 1440, 2, CAST(N'2022-10-28T08:26:13.520' AS DateTime), 1)
GO
INSERT [Sesion].[Token] ([IdToken], [Token], [VigenciaMinutos], [IdUsuario], [FechaIngreso], [Estado]) VALUES (154, N'bcWLbFcHnoLgOwLBkurWGYGZ3WUuY0No3PQdvB0qrbbNgcfXrKHG6H0js2WnvdXcdF28Gk9o7aP0POqatQ', 1, 1, CAST(N'2022-10-29T02:53:36.033' AS DateTime), 1)
GO
INSERT [Sesion].[Usuario] ([IdUsuario], [Nombres], [Apellidos], [Direccion], [Email], [Contrasenia], [IdUsuarioCreadoPor], [FechaIngreso], [Estado], [IdRol]) VALUES (1, N'Daniel', N'Juárez', N'Poptún', N'alexjr64@hotmail.com', N'/+SV3yev+rC1Idc9zsT21JS3D/DCsCTYYau4ry4dOPzfrTXzO5kIyQsWXwjqCX0YU2ge7FDu4K4KyF8USkKEjA==', 1, CAST(N'2022-07-30T19:12:21.380' AS DateTime), 1, 1)
GO
INSERT [Sesion].[Usuario] ([IdUsuario], [Nombres], [Apellidos], [Direccion], [Email], [Contrasenia], [IdUsuarioCreadoPor], [FechaIngreso], [Estado], [IdRol]) VALUES (2, N'Boris', N'Juárez', N'Poptún', N'boda-jume@hotmail.com', N'/+SV3yev+rC1Idc9zsT21JS3D/DCsCTYYau4ry4dOPzfrTXzO5kIyQsWXwjqCX0YU2ge7FDu4K4KyF8USkKEjA==', 1, CAST(N'2022-07-30T19:25:40.410' AS DateTime), 1, 2)
GO
INSERT [Sesion].[Usuario] ([IdUsuario], [Nombres], [Apellidos], [Direccion], [Email], [Contrasenia], [IdUsuarioCreadoPor], [FechaIngreso], [Estado], [IdRol]) VALUES (3, N'Elizabeth', N'Reyes', N'Poptún', N'elymary-mr@hotmail.com', N'/+SV3yev+rC1Idc9zsT21JS3D/DCsCTYYau4ry4dOPzfrTXzO5kIyQsWXwjqCX0YU2ge7FDu4K4KyF8USkKEjA==', 1, CAST(N'2022-07-30T19:31:24.283' AS DateTime), 1, 4)
GO
INSERT [Sesion].[Usuario] ([IdUsuario], [Nombres], [Apellidos], [Direccion], [Email], [Contrasenia], [IdUsuarioCreadoPor], [FechaIngreso], [Estado], [IdRol]) VALUES (4, N'Jacob', N'Cucul', N'Poptún', N'jacob@hotmail.com', N'28ZCAiDhJ5vKgVfieA2XpP1WvAc8XC+5cm9kPr7UPzstUl6yOV3oLCuvg43FRD/D+BilMlEd6aCX7ic8UvMdVw==', 1, CAST(N'2022-08-29T11:33:53.523' AS DateTime), 1, 3)
GO
INSERT [Sesion].[Usuario] ([IdUsuario], [Nombres], [Apellidos], [Direccion], [Email], [Contrasenia], [IdUsuarioCreadoPor], [FechaIngreso], [Estado], [IdRol]) VALUES (6, N'', N'', N'', N'', N'wqDFyl3W3ZXqw6/8qcl4dEADRWeQgQ+MMLe1q6F2Bry9rq8yNQJray0fAfJiaXYxJO73WrIlHUTweUk//kFv/w==', 1, CAST(N'2022-10-11T01:46:08.890' AS DateTime), 0, 4)
GO
ALTER TABLE [Atencion].[HistorialMedico] ADD  CONSTRAINT [DF_HistorialMedico_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Atencion].[HistorialMedico] ADD  CONSTRAINT [DF_HistorialMedico_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Atencion].[Paciente] ADD  CONSTRAINT [DF_Paciente_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Atencion].[Paciente] ADD  CONSTRAINT [DF_Paciente_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Compra].[CitaProveedor] ADD  CONSTRAINT [DF_CitaProveedor_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Compra].[CitaProveedor] ADD  CONSTRAINT [DF_CitaProveedor_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Compra].[CompraProveedor] ADD  CONSTRAINT [DF_Compra_IdEstadoCompra]  DEFAULT ((1)) FOR [IdEstadoCompra]
GO
ALTER TABLE [Compra].[CompraProveedor] ADD  CONSTRAINT [DF_PagoAProveedor_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Compra].[CompraProveedor] ADD  CONSTRAINT [DF_PagoAProveedor_IntEstado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Compra].[PagoAProveedor] ADD  CONSTRAINT [DF_PagoAProveedor_IdEstadoPago]  DEFAULT ((5)) FOR [IdEstadoPago]
GO
ALTER TABLE [Compra].[PagoAProveedor] ADD  CONSTRAINT [DF_Pago_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Compra].[Proveedor] ADD  CONSTRAINT [DF_Proveedor_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Compra].[Proveedor] ADD  CONSTRAINT [DF_Proveedor_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Sesion].[Menu] ADD  CONSTRAINT [DF_Menu_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Sesion].[MenuPorRol] ADD  CONSTRAINT [DF_MenuPorRol_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Sesion].[MenuPorRol] ADD  CONSTRAINT [DF_MenuPorRol_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Sesion].[Modulo] ADD  CONSTRAINT [DF_Modulo_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Sesion].[Rol] ADD  CONSTRAINT [DF_Rol_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Sesion].[Rol] ADD  CONSTRAINT [DF_Rol_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Sesion].[Token] ADD  CONSTRAINT [DF_Token_FechaIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Sesion].[Token] ADD  CONSTRAINT [DF_Token_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Sesion].[Usuario] ADD  CONSTRAINT [DF_Usuario_FechaDeIngreso]  DEFAULT (getdate()) FOR [FechaIngreso]
GO
ALTER TABLE [Sesion].[Usuario] ADD  CONSTRAINT [DF_Usuario_Estado]  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [Atencion].[HistorialMedico]  WITH CHECK ADD  CONSTRAINT [FK_HistorialMedico_Paciente] FOREIGN KEY([IdPaciente])
REFERENCES [Atencion].[Paciente] ([IdPaciente])
GO
ALTER TABLE [Atencion].[HistorialMedico] CHECK CONSTRAINT [FK_HistorialMedico_Paciente]
GO
ALTER TABLE [Atencion].[HistorialMedico]  WITH CHECK ADD  CONSTRAINT [FK_HistorialMedico_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Atencion].[HistorialMedico] CHECK CONSTRAINT [FK_HistorialMedico_Usuario]
GO
ALTER TABLE [Atencion].[Paciente]  WITH CHECK ADD  CONSTRAINT [FK_Paciente_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Atencion].[Paciente] CHECK CONSTRAINT [FK_Paciente_Usuario]
GO
ALTER TABLE [Compra].[CitaProveedor]  WITH CHECK ADD  CONSTRAINT [FK_CitaProveedor_Proveedor] FOREIGN KEY([IdProveedor])
REFERENCES [Compra].[Proveedor] ([IdProveedor])
GO
ALTER TABLE [Compra].[CitaProveedor] CHECK CONSTRAINT [FK_CitaProveedor_Proveedor]
GO
ALTER TABLE [Compra].[CitaProveedor]  WITH CHECK ADD  CONSTRAINT [FK_CitaProveedor_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Compra].[CitaProveedor] CHECK CONSTRAINT [FK_CitaProveedor_Usuario]
GO
ALTER TABLE [Compra].[CompraProveedor]  WITH CHECK ADD  CONSTRAINT [FK_CompraProveedor_EstadoCompra] FOREIGN KEY([IdEstadoCompra])
REFERENCES [Compra].[EstadoCompraPago] ([IdEstadoCompra])
GO
ALTER TABLE [Compra].[CompraProveedor] CHECK CONSTRAINT [FK_CompraProveedor_EstadoCompra]
GO
ALTER TABLE [Compra].[CompraProveedor]  WITH CHECK ADD  CONSTRAINT [FK_PagoAProveedor_Proveedor] FOREIGN KEY([IdProveedor])
REFERENCES [Compra].[Proveedor] ([IdProveedor])
GO
ALTER TABLE [Compra].[CompraProveedor] CHECK CONSTRAINT [FK_PagoAProveedor_Proveedor]
GO
ALTER TABLE [Compra].[CompraProveedor]  WITH CHECK ADD  CONSTRAINT [FK_PagoAProveedor_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Compra].[CompraProveedor] CHECK CONSTRAINT [FK_PagoAProveedor_Usuario]
GO
ALTER TABLE [Compra].[PagoAProveedor]  WITH CHECK ADD  CONSTRAINT [FK_Pago_CompraProveedor] FOREIGN KEY([IdCompra])
REFERENCES [Compra].[CompraProveedor] ([IdCompra])
GO
ALTER TABLE [Compra].[PagoAProveedor] CHECK CONSTRAINT [FK_Pago_CompraProveedor]
GO
ALTER TABLE [Compra].[PagoAProveedor]  WITH CHECK ADD  CONSTRAINT [FK_PagoAProveedor_EstadoCompra] FOREIGN KEY([IdEstadoPago])
REFERENCES [Compra].[EstadoCompraPago] ([IdEstadoCompra])
GO
ALTER TABLE [Compra].[PagoAProveedor] CHECK CONSTRAINT [FK_PagoAProveedor_EstadoCompra]
GO
ALTER TABLE [Compra].[Proveedor]  WITH CHECK ADD  CONSTRAINT [FK_Proveedor_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Compra].[Proveedor] CHECK CONSTRAINT [FK_Proveedor_Usuario]
GO
ALTER TABLE [Sesion].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Menu] FOREIGN KEY([IdMenuPadre])
REFERENCES [Sesion].[Menu] ([IdMenu])
GO
ALTER TABLE [Sesion].[Menu] CHECK CONSTRAINT [FK_Menu_Menu]
GO
ALTER TABLE [Sesion].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Modulo] FOREIGN KEY([IdModulo])
REFERENCES [Sesion].[Modulo] ([IdModulo])
GO
ALTER TABLE [Sesion].[Menu] CHECK CONSTRAINT [FK_Menu_Modulo]
GO
ALTER TABLE [Sesion].[MenuPorRol]  WITH CHECK ADD  CONSTRAINT [FK_MenuPorRol_Menu] FOREIGN KEY([IdMenu])
REFERENCES [Sesion].[Menu] ([IdMenu])
GO
ALTER TABLE [Sesion].[MenuPorRol] CHECK CONSTRAINT [FK_MenuPorRol_Menu]
GO
ALTER TABLE [Sesion].[MenuPorRol]  WITH CHECK ADD  CONSTRAINT [FK_MenuPorRol_Rol] FOREIGN KEY([IdRol])
REFERENCES [Sesion].[Rol] ([IdRol])
GO
ALTER TABLE [Sesion].[MenuPorRol] CHECK CONSTRAINT [FK_MenuPorRol_Rol]
GO
ALTER TABLE [Sesion].[MenuPorRol]  WITH CHECK ADD  CONSTRAINT [FK_MenuPorRol_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Sesion].[MenuPorRol] CHECK CONSTRAINT [FK_MenuPorRol_Usuario]
GO
ALTER TABLE [Sesion].[Rol]  WITH CHECK ADD  CONSTRAINT [FK_Rol_Usuario] FOREIGN KEY([IdUsuario])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Sesion].[Rol] CHECK CONSTRAINT [FK_Rol_Usuario]
GO
ALTER TABLE [Sesion].[Token]  WITH CHECK ADD  CONSTRAINT [FK_Token_Usuario] FOREIGN KEY([IdUsuario])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Sesion].[Token] CHECK CONSTRAINT [FK_Token_Usuario]
GO
ALTER TABLE [Sesion].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Rol] FOREIGN KEY([IdRol])
REFERENCES [Sesion].[Rol] ([IdRol])
GO
ALTER TABLE [Sesion].[Usuario] CHECK CONSTRAINT [FK_Usuario_Rol]
GO
ALTER TABLE [Sesion].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Usuario] FOREIGN KEY([IdUsuarioCreadoPor])
REFERENCES [Sesion].[Usuario] ([IdUsuario])
GO
ALTER TABLE [Sesion].[Usuario] CHECK CONSTRAINT [FK_Usuario_Usuario]
GO
/****** Object:  StoredProcedure [Atencion].[AgregarHistorialMedico]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[AgregarHistorialMedico]	(
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
GO
/****** Object:  StoredProcedure [Atencion].[AgregarPaciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[AgregarPaciente]	(
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
GO
/****** Object:  StoredProcedure [Atencion].[EliminarHistorialMedico]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[EliminarHistorialMedico]	(
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
GO
/****** Object:  StoredProcedure [Atencion].[EliminarPaciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[EliminarPaciente]	(
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
GO
/****** Object:  StoredProcedure [Atencion].[ModificarHistorialMedico]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ModificarHistorialMedico]	(
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
GO
/****** Object:  StoredProcedure [Atencion].[ModificarPaciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ModificarPaciente]	(
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
GO
/****** Object:  StoredProcedure [Atencion].[ObtenerDatosHistorialMedico]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ObtenerDatosHistorialMedico]	(	
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
GO
/****** Object:  StoredProcedure [Atencion].[ObtenerDatosPaciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ObtenerDatosPaciente]	(	
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
GO
/****** Object:  StoredProcedure [Atencion].[ObtenerHistorialesMedicos]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ObtenerHistorialesMedicos]
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
GO
/****** Object:  StoredProcedure [Atencion].[ObtenerHistorialesMedicosPaciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ObtenerHistorialesMedicosPaciente] (
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
GO
/****** Object:  StoredProcedure [Atencion].[ObtenerPacientes]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ObtenerPacientes] (
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
GO
/****** Object:  StoredProcedure [Atencion].[ObtenerUnPaciente]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Atencion].[ObtenerUnPaciente]	(	
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
GO
/****** Object:  StoredProcedure [Compra].[AgregarCitaProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[AgregarCitaProveedor]		(
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
GO
/****** Object:  StoredProcedure [Compra].[AgregarCompraProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[AgregarCompraProveedor]	(
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
GO
/****** Object:  StoredProcedure [Compra].[AgregarPagoProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[AgregarPagoProveedor]	(
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
GO
/****** Object:  StoredProcedure [Compra].[AgregarProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[AgregarProveedor] (
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
GO
/****** Object:  StoredProcedure [Compra].[EliminarCitaProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[EliminarCitaProveedor]	(
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
GO
/****** Object:  StoredProcedure [Compra].[EliminarCompraProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[EliminarCompraProveedor]	(
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
GO
/****** Object:  StoredProcedure [Compra].[EliminarProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[EliminarProveedor]	(
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
GO
/****** Object:  StoredProcedure [Compra].[ModificarCitaProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ModificarCitaProveedor]		(
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
GO
/****** Object:  StoredProcedure [Compra].[ModificarCompraProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ModificarCompraProveedor]		(
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
GO
/****** Object:  StoredProcedure [Compra].[ModificarProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ModificarProveedor]	(
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

	--SELECT	@_EmailRepetido = Email
	--FROM	Sesion.Usuario
	--WHERE	Email = @_Email

	--IF (@_Email = @_EmailRepetido)
		--BEGIN
	-- IF PARA EVITAR CAMPOS VACÍOS EN EL FORM DEL FRONTEND
	IF(@_Nombres = ''
		OR @_Apellidos = ''
		OR @_Telefono = ''
		OR @_LaboratorioClinico = '')
		BEGIN
			SELECT Alerta = 'Campos vacíos'
		END
		--END
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerCitasProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerCitasProveedor] (
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerCitasProveedores]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerCitasProveedores]
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerComprasProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerComprasProveedor] (
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerComprasProveedores]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerComprasProveedores]
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerDatosCitaProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerDatosCitaProveedor]	(	
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerDatosCompraProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerDatosCompraProveedor]	(	
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerDatosProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerDatosProveedor]		(	
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerPagosProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerPagosProveedor] (
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerPagosProveedores]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerPagosProveedores]
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerProveedores]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerProveedores] (
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
GO
/****** Object:  StoredProcedure [Compra].[ObtenerUnProveedor]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Compra].[ObtenerUnProveedor]	(	
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
GO
/****** Object:  StoredProcedure [Sesion].[ActualizarVigenciaToken]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[ActualizarVigenciaToken]	(
												@_Token		NVARCHAR(250)
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
GO
/****** Object:  StoredProcedure [Sesion].[AgregarUsuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[AgregarUsuario]	(
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
GO
/****** Object:  StoredProcedure [Sesion].[EliminarUsuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[EliminarUsuario]	(
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
GO
/****** Object:  StoredProcedure [Sesion].[IniciarSesion]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[IniciarSesion]	(
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

-- 
	BEGIN TRAN

		SELECT	@_UltimoId		=	ISNULL(MAX(a.IdToken),0)
		FROM	Sesion.Token	AS	a

		UPDATE	Sesion.Token
		SET		Estado = 0
		WHERE	IdUsuario =	@_IdUsuario
				AND Estado > 0

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
			SET @_Resultado				=	1
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
GO
/****** Object:  StoredProcedure [Sesion].[MenuUsuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[MenuUsuario]	(
									@_Token			NVARCHAR(250),
									@_IdModulo		TINYINT
								)
AS
DECLARE		@_IdUsuario INT	= 0
BEGIN

	SELECT	@_IdUsuario	= Sesion.ObtenerIdUsuario(@_Token)
	
	SELECT
			b.IdMenu,
			a.Nombre,
			a.URL,
			a.IdMenuPadre,
			a.TextoIcono,
			b.Agregar,
			b.Modificar,
			b.Eliminar,
			b.Consultar
	FROM
			Sesion.MenuPorRol						AS	b
			LEFT JOIN Sesion.Menu					AS	a
			ON a.IdMenu								=	b.IdMenu
			LEFT JOIN Sesion.Rol					AS	c
			ON c.IdRol								=	b.IdRol
			--LEFT JOIN Sesion.TblUsuariosPorRoles	AS	d
			--ON d.IdRol								=	c.IdRol
			LEFT JOIN Sesion.Usuario				AS	e
			ON e.IdUsuario							=	c.IdUsuario
	WHERE
			a.Estado								=	1
			AND a.IdModulo							=	@_IdModulo
			AND b.Estado							=	1
			AND c.Estado							=	1
			--AND d.IntEstado							=	1
			AND e.Estado							=	1
			AND c.IdUsuario							=	@_IdUsuario
			--AND	d.IdUsuario							=	@_IdUsuario
	ORDER BY
			a.OrdenMenu								ASC

END
GO
/****** Object:  StoredProcedure [Sesion].[ModificarUsuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[ModificarUsuario]	(
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
GO
/****** Object:  StoredProcedure [Sesion].[ObtenerDatosUsuario]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[ObtenerDatosUsuario]	(	
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
GO
/****** Object:  StoredProcedure [Sesion].[ObtenerEstadoToken]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[ObtenerEstadoToken]	(
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
GO
/****** Object:  StoredProcedure [Sesion].[ObtenerUsuarios]    Script Date: 29/10/2022 10:46:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Sesion].[ObtenerUsuarios]
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
GO
