USE[Proyecto 3]

BEGIN TRY
    BEGIN TRANSACTION;  -- Iniciar la transacción

    DECLARE @XmlData XML;

    -- Cargar el XML desde el archivo
    SELECT @XmlData = CONVERT(XML, BulkColumn)
    FROM OPENROWSET(BULK 'D:\Proyecto 3 Bases\OperacionesFinal.xml', SINGLE_BLOB) AS x;

    -- Insertar datos en la tabla TH
    INSERT INTO TH (Nombre, IdUsuario, FechaNacimiento, DocumentoIdentidad)
    SELECT 
        T.C.value('@Nombre', 'VARCHAR(128)'),
        U.id,
        T.C.value('@FechaNacimiento', 'DATE'),
        T.C.value('@ValorDocIdentidad', 'VARCHAR(32)')
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('NTH/NTH') AS T(C)
    JOIN Usuario U ON U.Username = T.C.value('@NombreUsuario', 'VARCHAR(64)');

    -- Insertar datos en la tabla TCM
    INSERT INTO TCM (Codigo, LimiteCredito, IdTipoTCM, IdTH)
    SELECT 
        T.C.value('@Codigo', 'INT'),
        T.C.value('@LimiteCredito', 'INT'),
        TT.id,
        TH.id
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('NTCM/NTCM') AS T(C)
    JOIN TipoTCM TT ON TT.Nombre = T.C.value('@TipoTCM', 'VARCHAR(64)')
    JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)');

    -- Insertar datos en la tabla TCA
    INSERT INTO TCA (IdTH, IdTCM, Codigo)
    SELECT 
        TH.id,
        TCM.id,
        T.C.value('@CodigoTCA', 'INT')
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('NTCA/NTCA') AS T(C)
    JOIN TH ON TH.DocumentoIdentidad = T.C.value('@TH', 'VARCHAR(32)')
    JOIN TCM ON TCM.Codigo = T.C.value('@CodigoTCM', 'INT');

    -- Insertar datos en la tabla TF
    INSERT INTO TF (Codigo, CodigoTC, FechaVencimiento, CCV)
    SELECT 
        T.C.value('@Codigo', 'BIGINT'),
        TCA.id,
        T.C.value('@FechaVencimiento', 'DATE'),
        T.C.value('@CCV', 'INT')
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('NTF/NTF') AS T(C)
    JOIN TCA ON TCA.Codigo = T.C.value('@TCAsociada', 'INT');

    -- Insertar datos en la tabla Movimientos
    INSERT INTO Movimientos (IdTF, Nombre, FechaMovimiento, Monto, Descripcion, Referencia, Sopechoso)
    SELECT 
        TF.id,
        T.C.value('@Nombre', 'VARCHAR(64)'),
        T.C.value('@FechaMovimiento', 'DATE'),
        T.C.value('@Monto', 'MONEY'),
        T.C.value('@Descripcion', 'VARCHAR(64)'),
        T.C.value('@Referencia', 'VARCHAR(64)'),
        0 -- Asumiendo valor por defecto para Sopechoso
    FROM @XmlData.nodes('/root/fechaOperacion') AS F(O)
    CROSS APPLY F.O.nodes('Movimiento/Movimiento') AS T(C)
    JOIN TF ON TF.Codigo = T.C.value('@TF', 'BIGINT');

    COMMIT TRANSACTION;  -- Confirmar la transacción si todo va bien
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;  -- Revertir la transacción en caso de error
    -- Registrar el error o manejarlo de acuerdo a tus necesidades
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;