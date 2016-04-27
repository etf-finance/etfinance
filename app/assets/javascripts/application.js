// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require_tree .
//= require bootstrap
//= require turbolinks

    var monthNames = ["jan.", "fév.", "mar.", "avr.", "mai", "juin",
      "juil.", "août", "sept.", "oct.", "nov.", "dec."
    ];
    var data_string = [{ "time": "2008", "value": "20" },{ "time": "2009", "value": "10" },{ "time": "2010", "value": "5" },{ "time": "2011", "value": "5" },{ "time": "2012", "value": "20" }];
    // var data_array = JSON.parse(data_string)
    $(document).ready(function() {
        barChart();

        // $(window).resize(function() {
        //     window.m.redraw();
        // });
    });



    function barChart() {



         Morris.Line({
      // ID of the element in which to draw the chart.
      element: 'line_chart',
      // Chart data records -- each entry in this array corresponds to a point on
      // the chart.
      data: $('#line_chart').data('bookings'),
      // The name of the data record attribute that contains x-values.
      xkey: 'date',
      // A list of names of data record attributes that contain y-values.
      ykeys: ['value'],

      resize: true,

      parseTime: false,


      // ymax: 10;

      dateFormat: function (x) { return new Date(x).getDate() + ' ' + monthNames[new Date(x).getMonth()]; },

      // xLabels: 'week',

      xLabelFormat: function (x) { return new Date(x).getDate() + ' ' + monthNames[new Date(x).getMonth()]; },

      // xLabelFormat: function (x) { return x; },




      // Labels for the ykeys -- will be displayed when you hover over the
      // chart.
      labels: ['Value']
    });





}