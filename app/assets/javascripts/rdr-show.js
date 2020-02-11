$(document).ready(function() {

  /* Toggle expand/collapse long text, e.g., description field on show page  */
  /* Used in concert with formatted_attribute_renderer.rb which creates the */
  /* accompanying markup. */

  $('a.toggle-extended-text').click(function(e){
    e.preventDefault();
    $(this).toggleClass('expanded');
    $(this).siblings(".expandable-extended-text").toggle();
    if ($(this).text() == '... [Read More]') {
      $(this).text('[Collapse]');
    } else {
      $(this).text('... [Read More]');
    }
  });

  $('a.vertical-breadcrumb-expander').click(function(e){
    e.preventDefault();
    $(this).toggleClass('expanded');
    $('.vertical-breadcrumb .can-collapse').slideToggle();
    if ($(this).text() == '[Show More...]') {
      $(this).text('[Collapse]');
    } else {
      $(this).text('[Show More...]');
    }
  });

});
