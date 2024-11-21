USE [Proyecto 3 BackUp]

-- Desactivar las restricciones de claves foráneas temporalmente
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Limpiar las tablas que tienen dependencias de otras
DELETE FROM dbo.EstadoCuenta;
DELETE FROM dbo.Movimientos;
DELETE FROM dbo.TF;
DELETE FROM dbo.SubEC;
DELETE FROM dbo.TCA;
DELETE FROM dbo.ReglasNegocio;
DELETE FROM dbo.TipoMovimientoCorriente;
DELETE FROM dbo.TipoMovimientoIntereses;
DELETE FROM dbo.TipoMovimientoMoratorios;
DELETE FROM dbo.TipoRN;
DELETE FROM dbo.TCM;
DELETE FROM dbo.TipoTCM;
DELETE FROM dbo.TH;
DELETE FROM dbo.TipoU;
DELETE FROM dbo.Usuario;
DELETE FROM dbo.MotivoInvalidacionTarjeta;

-- Reactivar las restricciones de claves foráneas
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";

-- (Opcional) Si necesitas reiniciar los IDs autoincrementales
EXEC sp_MSforeachtable "DBCC CHECKIDENT ( '?', RESEED, 0)";