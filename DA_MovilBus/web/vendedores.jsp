<%-- Panel de gestión de vendedores - solo ADMINISTRADOR --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.UsuarioDAO, model.Usuario, java.util.List"%>
<%
    UsuarioDAO userDAO = new UsuarioDAO();
    request.setAttribute("listaVendedores", userDAO.listarVendedores());
%>
<%
    // Control de acceso: solo ADMINISTRADOR
    Usuario userVen = (Usuario) session.getAttribute("usuarioSesion");
    if (userVen == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    if (!"ADMINISTRADOR".equalsIgnoreCase(userVen.getRol())) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    boolean esAdminVen = true;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Gestión de Vendedores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .password-input-group {
            position: relative;
        }
        .password-input-group .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #6c757d;
            padding: 0;
        }
        .password-input-group .toggle-password:hover {
            color: var(--mvb-orange);
        }
        .rol-badge {
            background: linear-gradient(135deg, #FF8A65, #FF6F00);
            color: white;
            font-size: .7rem;
            padding: .2rem .6rem;
            border-radius: 20px;
            font-weight: 600;
        }
    </style>
</head>
<body class="admin-body">
    <div class="toast-container" id="toastContainer"></div>

    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="vendedores" />
                <jsp:param name="esAdmin" value="true" />
            </jsp:include>

            <!-- Main Content -->
            <div class="col-md-10 main-content animate-fade">
                <!-- Mobile Navbar -->
                <nav class="navbar navbar-dark bg-dark rounded-3 mb-4 d-md-none p-3">
                    <span class="navbar-brand mb-0 fw-bold"><i class="bi bi-bus-front me-2"></i>MovilBus</span>
                    <div>
                        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm me-1"><i class="bi bi-speedometer2"></i></a>
                        <a href="LogoutServlet" class="btn btn-outline-danger btn-sm"><i class="bi bi-box-arrow-right"></i></a>
                    </div>
                </nav>

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-person-badge text-warning me-2"></i> Vendedores
                            <small>Gestión del personal de ventas de la empresa</small>
                        </h1>
                    </div>
                    <button class="btn btn-warning rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#modalVendedor" onclick="limpiarModal()">
                        <i class="bi bi-plus-lg me-1"></i> Nuevo Vendedor
                    </button>
                </div>

                <!-- Success/Error Messages -->
                <c:if test="${not empty sessionScope.msgExito}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-check-circle me-2"></i> ${sessionScope.msgExito}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="msgExito" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.msgError}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i> ${sessionScope.msgError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="msgError" scope="session"/>
                </c:if>

                <!-- Vendedores Table -->
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-warning"></i>Listado de Vendedores</h5>
                            <span class="badge bg-warning text-dark rounded-pill">${listaVendedores.size()} registros</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Usuario</th>
                                        <th>Nombre Completo</th>
                                        <th>Rol</th>
                                        <th class="text-center">Estado</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="v" items="${listaVendedores}">
                                        <tr>
                                            <td><span class="text-muted small fw-bold">#${v.idUsuario}</span></td>
                                            <td>
                                                <span class="fw-semibold">
                                                    <i class="bi bi-person me-1 text-muted"></i>${v.username}
                                                </span>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="rounded-circle bg-warning bg-opacity-10 p-2 me-2 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                                                        <i class="bi bi-person-badge text-warning"></i>
                                                    </div>
                                                    <div>
                                                        <span class="fw-semibold">${v.nombre} ${v.apellido}</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="rol-badge">
                                                    <i class="bi bi-shop me-1"></i>VENDEDOR
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${v.estado == 'ACTIVO'}">
                                                        <span class="badge badge-estado bg-success"><i class="bi bi-check-circle me-1"></i>${v.estado}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-estado bg-secondary"><i class="bi bi-x-circle me-1"></i>${v.estado}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <button class="btn btn-outline-warning btn-action me-1" title="Editar" 
                                                        onclick="editarVendedor(${v.idUsuario}, '${v.nombre}', '${v.apellido}', '${v.estado}')">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <c:if test="${v.estado != 'INACTIVO'}">
                                                    <form action="VendedorServlet" method="POST" class="d-inline" onsubmit="return confirm('¿Dar de baja al vendedor ${v.nombre} ${v.apellido}?\\n\\nEl vendedor perderá acceso al sistema.')">
                                                        <input type="hidden" name="accion" value="eliminar">
                                                        <input type="hidden" name="idUsuario" value="${v.idUsuario}">
                                                        <button class="btn btn-outline-danger btn-action" title="Dar de Baja">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaVendedores}">
                                        <tr>
                                            <td colspan="6">
                                                <div class="empty-state">
                                                    <i class="bi bi-person-badge text-muted"></i>
                                                    <p class="mb-0">No hay vendedores registrados en el sistema.</p>
                                                    <button class="btn btn-warning btn-sm mt-2" data-bs-toggle="modal" data-bs-target="#modalVendedor">
                                                        <i class="bi bi-plus-lg"></i> Registrar primer vendedor
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Crear/Editar Vendedor -->
    <div class="modal fade" id="modalVendedor" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold" id="modalTitle"><i class="bi bi-person-plus me-2 text-warning"></i>Registrar Vendedor</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="VendedorServlet" method="POST" id="formVendedor">
                    <div class="modal-body pt-0">
                        <input type="hidden" name="accion" id="accion" value="registrar">
                        <input type="hidden" name="idUsuario" id="idUsuario">
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-person me-1"></i>Nombre de Usuario</label>
                            <input type="text" class="form-control" name="username" id="username" placeholder="Ej: vendedor01" required>
                            <div class="form-text small">Username único para iniciar sesión en el sistema.</div>
                        </div>
                        
                        <!-- Campo contraseña: visible solo al crear -->
                        <div class="mb-3" id="campoPassword">
                            <label class="form-label"><i class="bi bi-lock me-1"></i>Contraseña</label>
                            <div class="password-input-group">
                                <input type="password" class="form-control" name="password" id="password" minlength="6" placeholder="Mínimo 6 caracteres" required>
                                <button type="button" class="toggle-password" onclick="togglePassword()" tabindex="-1">
                                    <i class="bi bi-eye" id="eyeIcon"></i>
                                </button>
                            </div>
                            <div class="form-text small">Elige una contraseña segura (mín. 6 caracteres).</div>
                        </div>
                        
                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label"><i class="bi bi-person me-1"></i>Nombres</label>
                                <input type="text" class="form-control" name="nombre" id="nombre" placeholder="Ej: Carlos" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label"><i class="bi bi-person me-1"></i>Apellidos</label>
                                <input type="text" class="form-control" name="apellido" id="apellido" placeholder="Ej: Ramírez" required>
                            </div>
                        </div>
                        
                        <div class="mb-3" id="campoEstado" style="display:none;">
                            <label class="form-label"><i class="bi bi-toggle-on me-1"></i>Estado</label>
                            <select class="form-select" name="estado" id="estado">
                                <option value="ACTIVO">ACTIVO</option>
                                <option value="INACTIVO">INACTIVO</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light rounded-pill" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-warning rounded-pill px-4 text-white" id="btnSubmit">
                            <i class="bi bi-save me-1"></i> Guardar
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function limpiarModal() {
            document.getElementById('accion').value = 'registrar';
            document.getElementById('idUsuario').value = '';
            document.getElementById('formVendedor').reset();
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-person-plus me-2 text-warning"></i>Registrar Vendedor';
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-save me-1"></i> Guardar';
            document.getElementById('campoPassword').style.display = 'block';
            document.getElementById('password').required = true;
            document.getElementById('username').disabled = false;
            document.getElementById('campoEstado').style.display = 'none';
        }

        function editarVendedor(id, nombre, apellido, estado) {
            document.getElementById('accion').value = 'actualizar';
            document.getElementById('idUsuario').value = id;
            document.getElementById('nombre').value = nombre;
            document.getElementById('apellido').value = apellido;
            document.getElementById('estado').value = estado;
            
            document.getElementById('username').disabled = true;
            document.getElementById('username').value = '';
            document.getElementById('username').placeholder = '(No editable)';
            document.getElementById('username').required = false;
            document.getElementById('campoPassword').style.display = 'none';
            document.getElementById('password').required = false;
            
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-pencil me-2 text-warning"></i>Editar Vendedor #' + id;
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-arrow-repeat me-1"></i> Actualizar';
            document.getElementById('campoEstado').style.display = 'block';
            
            var modal = new bootstrap.Modal(document.getElementById('modalVendedor'));
            modal.show();
        }

        function togglePassword() {
            var pwd = document.getElementById('password');
            var icon = document.getElementById('eyeIcon');
            if (pwd.type === 'password') {
                pwd.type = 'text';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                pwd.type = 'password';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        }

        // Validar formulario de vendedor
        document.getElementById('formVendedor').addEventListener('submit', function(e) {
            const username = document.getElementById('username').value.trim();
            const nombre = document.getElementById('nombre').value.trim();
            const apellido = document.getElementById('apellido').value.trim();
            const accion = document.getElementById('accion').value;

            if (accion === 'registrar') {
                const password = document.getElementById('password').value;
                if (username.length < 3) {
                    e.preventDefault();
                    alert('⚠️ El nombre de usuario debe tener al menos 3 caracteres.');
                    document.getElementById('username').focus();
                    return;
                }
                if (password.length < 6) {
                    e.preventDefault();
                    alert('⚠️ La contraseña debe tener al menos 6 caracteres.');
                    document.getElementById('password').focus();
                    return;
                }
            }

            if (nombre.length < 2) {
                e.preventDefault();
                alert('⚠️ El nombre debe tener al menos 2 caracteres.');
                document.getElementById('nombre').focus();
                return;
            }

            if (apellido.length < 2) {
                e.preventDefault();
                alert('⚠️ El apellido debe tener al menos 2 caracteres.');
                document.getElementById('apellido').focus();
                return;
            }
        });

        // Auto-dismiss alerts after 5 seconds
        setTimeout(function() {
            document.querySelectorAll('.alert').forEach(a => {
                var bsAlert = new bootstrap.Alert(a);
                setTimeout(() => bsAlert.close(), 4000);
            });
        }, 5000);
    </script>
</body>
</html>
