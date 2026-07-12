# Sistema Web de Gestión de Transporte Interprovincial - Movil Bus (Chiclayo)

Este proyecto consiste en el desarrollo de una aplicación web dinámica diseñada para automatizar y optimizar los procesos operativos y comerciales de la empresa de transporte interprovincial **Movil Bus** en la ciudad de Chiclayo. Desarrollado como parte del curso de **Desarrollo de Aplicaciones** en la **Universidad Señor de Sipán**.

---

## Miembros del Equipo
* **Ortiz Santisteban Brando Nahum**
* **Pizarro Echeandia Arni Enoc**
* **Puicon Perleche Mislena Katherine**
* **Ramirez Vasquez Fernando Gabriel**
* **Risco Rodriguez Franklin Armando**

**Docente:** Mg. Vidaurre Flores Miguel Ángel

---

## Descripción del Proyecto
El sistema centraliza las operaciones clave de la empresa en una plataforma única, eliminando registros manuales y mejorando el control de la información para los operadores y administradores. 

El núcleo funcional del software destaca por implementar una relación **Maestro-Detalle** entre la programación de un viaje y la emisión de los pasajes correspondientes.

### Módulos Principales
* **Gestión de Clientes:** Registro, consulta y actualización de pasajeros.
* **Gestión de Buses:** Control del inventario de la flota (placa, capacidad, estado operativo).
* **Gestión de Rutas:** Administración de trayectos (orígenes, destinos).
* **Programación de Viajes:** Asignación de buses, rutas y conductores a fechas y horas específicas.
* **Venta de Pasajes:** Módulo para seleccionar viajes, asignar asientos disponibles y calcular tarifas en tiempo real.
* **Módulo de Pagos:** Registro de transacciones asociadas a cada pasaje según su método de pago.
* **Control Operativo (Despacho):** Control de andenes, salidas físicas en tiempo real y generación del manifiesto oficial de pasajeros.

---

## Stack Tecnológico
El proyecto adopta una arquitectura clásica en capas que asegura una separación limpia de responsabilidades:

* **Capa de Presentación:** JavaServer Pages (JSP), HTML5, CSS.
* **Capa de Control:** Java EE Servlets (Manejo de peticiones HTTP Request/Response).
* **Capa de Datos:** Patrón DAO (Data Access Object) mediante la API de JDBC.
* **Motor de Base de Datos:** Microsoft SQL Server .

---

## Arquitectura y Diseño del Sistema

### Arquitectura de Componentes
El flujo de datos sigue un recorrido lineal y estructurado a través de las capas definidas en el diseño académico:
`Interfaz de Usuario (JSP) ➔ Servlets Controlador ➔ Lógica de Negocio ➔ DAO (JDBC) ➔ SQL Server Database`

### Modelo Físico de Base de Datos
El esquema relacional mapea completamente la lógica del negocio a través de 10 tablas interconectadas para garantizar la integridad referencial:
1. **Roles / Usuarios:** Control de accesos y seguridad del personal de terminal.
2. **Ciudades / Rutas:** Catálogo de destinos interprovinciales.
3. **Conductores / Bus:** Administración de los recursos humanos y técnicos de la flota.
4. **Viaje:** El nodo maestro que unifica bus, ruta, conductor y horario.
5. **Cliente / Pasaje / Pago:** Flujo transaccional de cara al pasajero.

---

## Cronograma General de Desarrollo
El proyecto contempla un ciclo de vida incremental enfocado en las siguientes metas clave:
* **Fase 1:** Análisis de requerimientos y diseño del modelo físico de datos.
* **Fase 2:** Programación de la conectividad JDBC y construcción de CRUDs básicos.
* **Fase 3:** Desarrollo de interfaces JSP y Servlets de control transaccional.
* **Fase 4:** Pruebas de concurrencia, integración de pasajes .