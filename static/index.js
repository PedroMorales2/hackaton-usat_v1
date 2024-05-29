$(document).ready(function() {
    $('.clickable-row').click(function() {
        // Verifica si ya existe una fila de acciones debajo y la elimina si es así
        if ($(this).next().hasClass('actions-row')) {
            $(this).next().remove();
        } else {
            // Remover cualquier otra fila de acciones abierta
            $('.actions-row').remove();
            // Obtener el ID del semestre de la fila
            var semestreId = $(this).data('id');
            // Crear la fila de acciones
            var actionsRow = '<tr class="actions-row"><td colspan="5">' +
                '<a href="/editar_semestre/' + semestreId + '" class="btn btn-warning">Editar</a> ' +
                '<a href="/eliminar_semestre/' + semestreId + '" class="btn btn-danger">Eliminar</a> ' +
                '<a href="/agregar_cursos/' + semestreId + '" class="btn btn-info">Agregar Cursos</a>' +
                '</td></tr>';
            // Insertar la fila de acciones debajo de la fila clickeada
            $(this).after(actionsRow);
        }
    });
});