-- Crear tabla con columna BFILE
CREATE TABLE documentos_externos (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(200),
    descripcion VARCHAR2(500),
    archivo BFILE,
    fecha_registro DATE DEFAULT SYSDATE
);

-- Insertar referencia a archivo PDF
INSERT INTO documentos_externos (nombre, descripcion, archivo)
VALUES ('Manual_Usuario', 'Manual de usuario en PDF', 
        BFILENAME('ARCHIVOS_DIR', 'manual.pdf'));

-- Insertar referencia a imagen
INSERT INTO documentos_externos (nombre, descripcion, archivo)
VALUES ('Logo_Empresa', 'Logo corporativo PNG', 
        BFILENAME('ARCHIVOS_DIR', 'logo.png'));

-- Insertar referencia a documento Word
INSERT INTO documentos_externos (nombre, descripcion, archivo)
VALUES ('Contrato_Base', 'Plantilla de contrato DOCX', 
        BFILENAME('ARCHIVOS_DIR', 'contrato.docx'));

COMMIT;

--No existen
SELECT d.id, d.nombre,
       DBMS_LOB.FILEEXISTS(d.archivo) as ruta_archivo
FROM documentos_externos d;


--Vamos a crear 1

CREATE OR REPLACE PROCEDURE crear_archivo_y_bfile (
    p_nombre_archivo IN VARCHAR2,
    p_contenido IN VARCHAR2
) IS
    v_archivo UTL_FILE.FILE_TYPE;
    v_bfile BFILE;
BEGIN
    -- 1. Crear archivo físico usando UTL_FILE
    v_archivo := UTL_FILE.FOPEN('ARCHIVOS_DIR', p_nombre_archivo, 'W');
    UTL_FILE.PUT_LINE(v_archivo, p_contenido);
    UTL_FILE.FCLOSE(v_archivo);
    
    DBMS_OUTPUT.PUT_LINE('Archivo creado: ' || p_nombre_archivo);
    
    -- 2. Insertar referencia BFILE a la tabla
    INSERT INTO documentos_externos (nombre, descripcion, archivo)
    VALUES (p_nombre_archivo, 'Prueba: '||p_nombre_archivo, 
        BFILENAME('ARCHIVOS_DIR', p_nombre_archivo));
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('BFILE creado en la tabla');
    
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_archivo) THEN
            UTL_FILE.FCLOSE(v_archivo);
        END IF;
        RAISE;
END crear_archivo_y_bfile;

BEGIN
END;

/
-- Ejecutar procedimiento para crear archivos
BEGIN
    crear_archivo_y_bfile('documento_curso.txt', 
        'Este es un archivo creado desde PL/SQL para el curso de Oracle.');
END;
