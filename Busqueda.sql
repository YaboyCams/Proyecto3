USE [Proyecto 3 BackUp];

DECLARE @Usuario_id INT;

-- Paso 1: Obtener el id del usuario dado su username y guardarlo en la variable
SELECT @Usuario_id = id
FROM dbo.Usuario
WHERE username = 'aalfaro';

-- Eliminar tablas temporales si ya existen
IF OBJECT_ID('tempdb..#TempTH') IS NOT NULL DROP TABLE #TempTH;
IF OBJECT_ID('tempdb..#TempTCM') IS NOT NULL DROP TABLE #TempTCM;
IF OBJECT_ID('tempdb..#TempTCA') IS NOT NULL DROP TABLE #TempTCA;

-- Paso 2: Usar el id del usuario para buscar en la tabla TH
SELECT th.*
INTO #TempTH
FROM dbo.TH th
WHERE th.IdUsuario = @Usuario_id;

-- Paso 3: Usar los ids de TH para buscar en la tabla TCM
SELECT tcm.*
INTO #TempTCM
FROM dbo.TCM tcm
INNER JOIN #TempTH th ON tcm.IdTH = th.id;

-- Paso 4: Usar los ids de TCM para buscar en la tabla TCA
SELECT tca.*
INTO #TempTCA
FROM dbo.TCA tca
INNER JOIN #TempTCM tcm ON tca.IdTCM = tcm.id;

-- Paso 5: Usar los ids de TCA para buscar en la tabla TF
SELECT tf.*
FROM dbo.TF tf
INNER JOIN #TempTCA tca ON tf.IdTCA = tca.id;

-- Limpiar tablas temporales
DROP TABLE #TempTH;
DROP TABLE #TempTCM;
DROP TABLE #TempTCA;