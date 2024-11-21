USE [Proyecto 3];
GO

-- Drop the existing stored procedure if it exists
IF OBJECT_ID('GetUserCards', 'P') IS NOT NULL
    DROP PROCEDURE GetUserCardsAdmin;
GO

-- Create the new stored procedure
CREATE PROCEDURE GetUserCardsAdmin
    
AS
BEGIN
    SET NOCOUNT ON;

   

    -- Eliminar tablas temporales si ya existen
    IF OBJECT_ID('tempdb..#TempTH') IS NOT NULL DROP TABLE #TempTH;
    IF OBJECT_ID('tempdb..#TempTCM') IS NOT NULL DROP TABLE #TempTCM;
    IF OBJECT_ID('tempdb..#TempTCA') IS NOT NULL DROP TABLE #TempTCA;

    -- Paso 2: Usar el id del usuario para buscar en la tabla TH
    SELECT th.*
    INTO #TempTH
    FROM dbo.TH th
    

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

    -- Paso 5: Obtener todas las tarjetas de la tabla TF relacionadas con el usuario
    SELECT DISTINCT 
        tf.*,
        CASE 
            WHEN tf.IdMotivoInvalidacion IS NULL THEN 'ACTIVO'
            ELSE 'INACTIVO'
        END AS Status,
        CASE 
            WHEN tf.IdTCM IN (SELECT id FROM #TempTCM) THEN 'TCM'
            WHEN tf.IdTCA IN (SELECT id FROM #TempTCA) THEN 'TCA'
        END AS SourceTable
    FROM dbo.TF tf
    WHERE tf.IdTCM IN (SELECT id FROM #TempTCM)
       OR tf.IdTCA IN (SELECT id FROM #TempTCA);

    -- Limpiar tablas temporales
    DROP TABLE #TempTH;
    DROP TABLE #TempTCM;
    DROP TABLE #TempTCA;
END;
GO