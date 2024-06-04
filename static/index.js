$(document).ready(function() {
    $('.clickable-row').click(function() {
        if ($(this).next().hasClass('actions-row')) {
            $(this).next().remove();
        } else {
            $('.actions-row').remove();
            var semestreId = $(this).data('id');
            var actionsRow = '<tr class="actions-row text-center "><td colspan="6">' +
                '<a href="/editar_semestre/' + semestreId + '" class="btn btn-secondary">Editar</a> ' +
                '<a href="/eliminar_semestre/' + semestreId + '" class="btn btn-danger">Eliminar</a> ' +
                '<a href="/agregar_grupos/' + semestreId + '" class="btn btn-info">Agregar Grupo</a> ' +
                '<a href="/listar_gruposXID/' + semestreId + '" class="btn btn-primary">Ver Grupos</a> ' +
                '<a href="/dar_baja_semestre/' + semestreId + '" class="btn btn-warning">Dar baja</a> ' +
                '<a href="/dar_alta_semestre/' + semestreId + '" class="btn btn-success">Dar alta</a> ' +
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

function ajustarDuracion(index) {
    var tipoSustentacion = document.getElementById('tipoSustentacion-' + index).value;
    var campoDuracion = document.getElementById('minutos-' + index);
    
    if (tipoSustentacion === 'parcial') {
        campoDuracion.value = 30;  
    } else if (tipoSustentacion === 'final') {
        campoDuracion.value = 60;
    }
}
