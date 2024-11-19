USE [Proyecto 3 BackUp]

DECLARE @XmlData XML;

BEGIN TRANSACTION;

BEGIN TRY
    -- Load the XML data from the file
    SELECT @XmlData = CONVERT(XML, BulkColumn)
    FROM OPENROWSET(BULK 'D:\Proyecto 3 Bases\OperacionesFinal.xml', SINGLE_BLOB) AS x;

    -- Temporary table to store new users
    DROP TABLE IF EXISTS #TempUsuarios;
    CREATE TABLE #TempUsuarios (
        NombreUsuario VARCHAR(64),
        Password VARCHAR(50)
    );

    -- Collect new users
    INSERT INTO #TempUsuarios (NombreUsuario, Password)
    SELECT DISTINCT
        T.C.value('@NombreUsuario', 'VARCHAR(64)'),
        T.C.value('@Password', 'VARCHAR(50)')
    FROM @XmlData.nodes('/root/fechaOperacion/NTH/NTH') AS T(C)
    LEFT JOIN Usuario U ON U.Username = T.C.value('@NombreUsuario', 'VARCHAR(64)')
    WHERE U.Username IS NULL;

    -- Insert new users into the Usuario table
    INSERT INTO Usuario (Username, Password, IdTipoU)
    SELECT NombreUsuario, Password, 2
    FROM #TempUsuarios;

    -- Insert data into the TH table
    INSERT INTO TH (Nombre, IdUsuario, FechaNacimiento, DocumentoIdentidad, FechaCreacion)
    SELECT 
        T.C.value('@Nombre', 'VARCHAR(128)'),
        U.id,
        TRY_CONVERT(DATE, T.C.value('@FechaNacimiento', 'VARCHAR(10)'), 111),
        T.C.value('@ValorDocIdentidad', 'VARCHAR(32)'),
        F.O.value('@Fecha', 'DATE')
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('NTH/NTH') AS T(C)
    JOIN Usuario U ON U.Username = T.C.value('@NombreUsuario', 'VARCHAR(64)');

    -- Insert data into the TCM table
    INSERT INTO TCM (Codigo, LimiteCredito, IdTipoTCM, IdTH)
    SELECT 
        T.C.value('@Codigo', 'INT'),
        T.C.value('@LimiteCredito', 'INT'),
        TT.id,
        TH.id
    FROM @XmlData.nodes('/root/fechaOperacion/NTCM/NTCM') AS T(C)
    JOIN TipoTCM TT ON TT.Nombre = T.C.value('@TipoTCM', 'VARCHAR(64)')
    JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)');

    -- Insert data into the TCA table
    INSERT INTO TCA (IdTH, IdTCM, Codigo)
    SELECT 
        TH.id,
        TCM.id,
        T.C.value('@CodigoTCA', 'INT')
    FROM @XmlData.nodes('/root/fechaOperacion/NTCA/NTCA') AS T(C)
    JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)')
    JOIN TCM ON TCM.Codigo = T.C.value('@CodigoTCM', 'INT');

    -- Insert data into the TF table
    INSERT INTO TF (Codigo, CodigoTC, FechaVencimiento, CCV)
    SELECT 
        T.C.value('@Codigo', 'BIGINT'),
        TCA.id,
        TRY_CONVERT(DATE, CONCAT('01/', T.C.value('@FechaVencimiento', 'VARCHAR(7)')), 103),
        T.C.value('@CCV', 'INT')
    FROM @XmlData.nodes('/root/fechaOperacion/NTF/NTF') AS T(C)
    JOIN TCA ON TCA.Codigo = T.C.value('@TCAsociada', 'INT');

    -- Update TF table with IdTCM and IdTCA
    UPDATE TF
    SET IdTCM = CASE 
                    WHEN TCM.Codigo IS NOT NULL THEN TCM.Id 
                    ELSE NULL 
                END,
        IdTCA = CASE 
                    WHEN TCA.Codigo IS NOT NULL THEN TCA.Id 
                    ELSE NULL 
                END
    FROM TF
    LEFT JOIN TCM ON TCM.Codigo = TF.Codigo
    LEFT JOIN TCA ON TCA.Codigo = TF.Codigo;

    -- Insert data into the Movimientos table
    INSERT INTO Movimientos (IdTF, Nombre, FechaMovimiento, Monto, Descripcion, Referencia, Sopechoso)
    SELECT 
        TF.id,
        T.C.value('@Nombre', 'VARCHAR(64)'),
        TRY_CONVERT(DATE, T.C.value('@FechaMovimiento', 'VARCHAR(10)'), 111),
        T.C.value('@Monto', 'MONEY'),
        T.C.value('@Descripcion', 'VARCHAR(64)'),
        T.C.value('@Referencia', 'VARCHAR(64)'),
        0 -- Assuming default value for Sopechoso
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('Movimiento/Movimiento') AS T(C)
    JOIN TF ON TF.Codigo = T.C.value('@TF', 'BIGINT');

    COMMIT TRANSACTION;  -- Confirm the transaction if everything goes well
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;  -- Rollback the transaction in case of error
    -- Log the error or handle it according to your needs
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;