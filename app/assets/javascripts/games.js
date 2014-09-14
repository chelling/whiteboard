// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function change_scores_url(value)
{
  window.location.href = "scores?year=" + value;
}

function change_pickem_url(value)
{
  window.location.href = "pickem?year=" + value;
}

function change_fooicide_url(value)
{
    window.location.href = "fooicide?year=" + value;
}