$(document).ready(function() {
    $('.clickable-row').click(function() {
        if ($(this).next().hasClass('actions-row')) {
            $(this).next().remove();
        } else {
            $('.actions-row').remove();
            var semestreId = $(this).data('id');
            var actionsRow = '<tr class="actions-row"><td colspan="6">' +
                '<a href="/editar_semestre/' + semestreId + '" class="btn btn-warning">Editar</a> ' +
                '<a href="/eliminar_semestre/' + semestreId + '" class="btn btn-danger">Eliminar</a> ' +
                '<a href="/agregar_grupos/' + semestreId + '" class="btn btn-info">Agregar Cursos</a> ' +
                '<a href="/listar_gruposXID/' + semestreId + '" class="btn btn-primary">VER Cursos</a>' +
                '</td></tr>';
            $(this).after(actionsRow);
        }
    });
});


function updateDatesBasedOnWeeks(weekNumbers, index) {
    const weeks = weekNumbers.split(',').map(Number).sort((a, b) => a - b);
    if (weeks.length === 0 || isNaN(weeks[0])) {
        alert("Por favor, ingrese semanas válidas.");
        return;
    }

    const startOfYear = new Date(new Date().getFullYear(), 0, 1);
    const firstWeekDay = (weeks[0] - 1) * 7;
    const startDate = new Date(startOfYear);
    startDate.setDate(startDate.getDate() + firstWeekDay);

    const lastWeekDay = (weeks[weeks.length - 1] - 1) * 7 + 6;
    const endDate = new Date(startOfYear);
    endDate.setDate(endDate.getDate() + lastWeekDay);

    document.getElementById('startDate-' + index).value = formatDate(startDate);
    document.getElementById('endDate-' + index).value = formatDate(endDate);
}

function formatDate(date) {
    let d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [year, month, day].join('-');
}
