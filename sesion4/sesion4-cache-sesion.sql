CREATE OR REPLACE PACKAGE contexto_usuario AS
    PROCEDURE set_usuario(id NUMBER, nombre VARCHAR2);
    FUNCTION get_usuario_id RETURN NUMBER;
    FUNCTION get_usuario_nombre RETURN VARCHAR2;
END contexto_usuario;
/

CREATE OR REPLACE PACKAGE BODY contexto_usuario AS
    g_usuario_id    NUMBER;
    g_usuario_nombre VARCHAR2(100);
    
    PROCEDURE set_usuario(id NUMBER, nombre VARCHAR2) IS
    BEGIN
        g_usuario_id := id;
        g_usuario_nombre := nombre;
    END;
    
    FUNCTION get_usuario_id RETURN NUMBER IS
    BEGIN
        RETURN g_usuario_id;
    END;
    
    FUNCTION get_usuario_nombre RETURN VARCHAR2 IS
    BEGIN
        RETURN g_usuario_nombre;
    END;
END contexto_usuario;
/
  
-- Sesión 1 (Usuario A)
BEGIN
    contexto_usuario.set_usuario(101, 'Juan Pérez');
    -- Ahora cualquier procedimiento puede saber quién es el usuario SIN pasar parámetros
END;
/
-- En cualquier lugar de la misma sesión:
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usuario actual: ' || contexto_usuario.get_usuario_nombre());
    -- Output: Usuario actual: Juan Pérez
END;
/----------------------------------------------------------
-- Sesión 2 (Usuario B) - AL MISMO TIEMPO
BEGIN
    contexto_usuario.set_usuario(202, 'María García');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usuario actual: ' || contexto_usuario.get_usuario_nombre());
    -- Output: Usuario actual: María García
END;
