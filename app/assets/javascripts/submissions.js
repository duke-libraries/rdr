// Script for submissions

var submitForm = false;
var currentTab = 0; // First tab is 0
var totalTabs = 7;
showTab(currentTab); // Display the current tab

// slow down double clicking
$('#nextBtn, #prevBtn').click(function() {
  var mySelf = $(this);
  mySelf.addClass('disabled');
  setTimeout(function(){
    mySelf.removeClass('disabled');
  }, 350);
});

function showTab(n) {
  var theFormTab = document.getElementsByClassName("form-tab");
  theFormTab[n].style.display = "block";

  if (n == 0) {
    document.getElementById("prevBtn").style.display = "none";
  } else {
    document.getElementById("prevBtn").style.display = "inline";
  }

  // Change 'next' to 'submit' on last tab
  if (currentTab == totalTabs) {
    document.getElementById("nextBtn").innerHTML =
      "<span class='sr-only'>Submit</span><span aria-hidden='true'>Submit &gt;&gt;</span>";
  }

  if (currentTab == 2) {

    // reset data sizes if needed
    if ( $("input[name='submission[screening_funding]']:checked").val() == "yes" ) {
      $('#nonfunded-size-1').parent().removeClass( "active" );
      $('#nonfunded-size-2').parent().removeClass( "active" );
      document.getElementById("nonfunded-size-1").checked = false;
      document.getElementById("nonfunded-size-2").checked = false;
    }
    if ( $("input[name='submission[screening_funding]']:checked").val() == "no" ) {
      $('#funded-size-1').parent().removeClass( "active" );
      $('#funded-size-2').parent().removeClass( "active" );
      document.getElementById("funded-size-1").checked = false;
      document.getElementById("funded-size-2").checked = false;
    }
  }

  if (currentTab == 5) {
    // set error display if needed
    if ($("#t5 .text-area-empty").length > 0) {
      addError();
    } else {
      removeError();
    }
  }

  if (currentTab == 6) {
    // set error display if needed
    if ( $("input[name='submission[doi_exists]']:checked").val() == "yes" && $("#submission_doi").val() == '' ) {
      addError();
      document.getElementById("submission_doi").classList.add("text-area-empty");
    } else {
      removeError();
      document.getElementById("submission_doi").classList.remove("text-area-empty");
    }
  }

  if (currentTab == 7) {
    // set error display if needed
    if ( $("input[name='submission[using_cc0]']:checked").val() == "will not use cc0" && $("#t7 select").val() == '' ) {
      addError();
      document.getElementById("submission_license").classList.add("text-area-empty");
    } else {
      removeError();
      document.getElementById("submission_license").classList.remove("text-area-empty");
    }
  }

}

function nextPrev(n) {
  var theFormTab = document.getElementsByClassName("form-tab");

  if (n == 1 && !validateForm()) {
    return false;
  }

  if ((n == 1 && submitForm == true) || (n == 1 && currentTab == totalTabs)) {

    // disable submit button to prevent weird things from happening
    document.getElementById("nextBtn").classList.add("disabled");
    document.getElementById("nextBtn").disabled = true;

    // display modal about submission having happened
    $('#submitModal').modal({backdrop: 'static', keyboard: false});



    // submit the form
    document.getElementById("new_submission").submit();

    // reset radio button values
    document.getElementById("submission_screening_pii_no").checked = false;
    document.getElementById("submission_screening_pii_yes").checked = false;
    document.getElementById("submission_screening_funding_yes").checked = false;
    document.getElementById("submission_screening_funding_no").checked = false;
    document.getElementById("funded-size-1").checked = false;
    document.getElementById("funded-size-2").checked = false;
    document.getElementById("nonfunded-size-1").checked = false;
    document.getElementById("nonfunded-size-2").checked = false;
    document.getElementById("deposit-agreement-1").checked = false;

    return false;
  }

  theFormTab[currentTab].style.display = "none";

  // if previous button
  if (n == -1) {
    submitForm = false;
    removeError();
    document.getElementById("nextBtn").innerHTML =
      "<span class='sr-only'>Next</span><span aria-hidden='true'>&gt;&gt;</span>";
    document.getElementById("t" + currentTab).focus(); // focus on content
  }

  currentTab = currentTab + n;

  // console.log('current tab: ' + currentTab);

  showTab(currentTab);
}


// string values passed from rails constants
var t3a_exclude = document.getElementById("submission-values").getAttribute("data-t3-more-than-2-5");
var t3b_exclude = document.getElementById("submission-values").getAttribute("data-t3-more-than-10");
var t4_exclude = document.getElementById("submission-values").getAttribute("data-t4-not-agree");
var t7_exclude = document.getElementById("submission-values").getAttribute("data-t7-not-use");



function validateForm() {
  var myFormTab,
    myInput,
    myTextArea,
    i,
    j,
    valid = true;

  myFormTab = document.getElementsByClassName("form-tab");
  myInput = myFormTab[currentTab].getElementsByTagName("input");
  myTextArea = myFormTab[currentTab].getElementsByTagName("textarea");

  // Check every input field in the current tab:
  for (i = 0; i < myInput.length; i++) {
    // If it's a radio button
    if (myInput[i].type == "radio") {
      if (myInput[i].checked == true) {
        // Submit early for certain responses

        if (currentTab == 0) {
          document.getElementById("nextBtn").classList.remove("disabled");
        }

        if (currentTab == 1 && myInput[i].value == "yes") {
          submitForm = true;
        }

        if (currentTab == 3 && myInput[i].value == t3b_exclude) {
          submitForm = true;
        }

        if (currentTab == 3 && myInput[i].value == t3a_exclude) {
          submitForm = true;
        }

        if (currentTab == 4 && myInput[i].value == t4_exclude) {
          //submitForm = true;
        }

        // Implement skip logic

        if (currentTab == 2 && myInput[i].value == "no") {
          document.getElementById("screening-3a").classList.add("hidden");
          document.getElementById("screening-3b").classList.remove("hidden");
          document.getElementById("funded-size-1").disabled = true;
          document.getElementById("funded-size-2").disabled = true;
          document.getElementById("nonfunded-size-1").disabled = false;
          document.getElementById("nonfunded-size-2").disabled = false;
        }

        if (currentTab == 2 && myInput[i].value == "yes") {
          document.getElementById("screening-3a").classList.remove("hidden");
          document.getElementById("screening-3b").classList.add("hidden");
          document.getElementById("funded-size-1").disabled = false;
          document.getElementById("funded-size-2").disabled = false;
          document.getElementById("nonfunded-size-1").disabled = true;
          document.getElementById("nonfunded-size-2").disabled = true;
        }

        // Manually check funding size (byproduct of skip logic)
        if ( currentTab == 3 && $("input[name='submission[screening_funding]']:checked").val() == "yes" ) {
          checkingVal = $("input[name='submission[screening_funded_size]']:checked").val();
          if ( !checkingVal ) {
            addError();
            valid = false;
            break;
          }
        }

        if ( currentTab == 3 && $("input[name='submission[screening_funding]']:checked").val() == "no" ) {
          checkingVal = $("input[name='submission[screening_nonfunded_size]']:checked").val();
          if ( !checkingVal ) {
            addError();
            valid = false;
            break;
          }
        }

        // Manually check text field inputs

        if (currentTab == 6 && myInput[i].value == "yes") {
          if (document.getElementById("submission_doi").value == "") {
            document.getElementById("submission_doi").classList.add("text-area-empty");
            addError();
            valid = false;
            break;
          }

          if (document.getElementById("submission_doi").value != "") {
            document
              .getElementById("submission_doi")
              .classList.remove("text-area-empty");
          }
        }

        if (currentTab == 7 && myInput[i].value == t7_exclude) {
          if (document.getElementById("submission_license").value == "") {
            addError();
            valid = false;
            break;
          }

          if (document.getElementById("submission_license").value != "") {
            document.getElementById("submission_license").classList.remove("text-area-empty");
          }
        }

        valid = true;
        removeError();
        document.getElementById("t" + currentTab).focus();

        break;

      } else if (myInput[i].checked == false) {
        valid = false;
        addError();
        window.location.hash = "#form_alert" + currentTab;
      }
    }
  }

  // Loop through text areas
  for (j = 0; j < myTextArea.length; j++) {
    if (myTextArea[j].required) {
      if (myTextArea[j].value == "") {
        valid = false;
        myTextArea[j].classList.add("text-area-empty");
        addError();
      }

      if (myTextArea[j].value != "") {
        myTextArea[j].classList.remove("text-area-empty");
      }
    }
  }

  return valid;
}


// +++ clean up error display +++ //

  // undo disabled nextBtn for radio buttons
  $(function() {

    $('input[type="radio"]').bind('change', function () {
      document.getElementById("nextBtn").classList.remove("disabled");
    });

  });

  // undo disabled nextBtn for text areas (tab 5)
  $( "#t5 textarea" ).on("change", function() {
      
    var zeroCount = 0;

    $(".text-area-empty").each(function() {
      if ( $(this).val().length == 0) {
        zeroCount++
      } else {
        $(this).removeClass( "text-area-empty" );
      }
    });

    if (zeroCount == 0) {
      removeError();
    }
  
  });

  // undo disabled nextBtn for text input (tab 6)
  $(function() {

    $('#t6 input[type="text"]').bind('change', function () {
      if ( $(this).val().length != 0) {
        $(this).removeClass( "text-area-empty" );
        document.getElementById("nextBtn").classList.remove("disabled");
      }
    });

  });

  // undo disabled nextBtn for select (tab 7)
  $( "#t7 select" ).on("change", function() {

    if ($(this).val() != '') {
      document.getElementById("nextBtn").classList.remove("disabled");
      $(this).removeClass( "text-area-empty" );
    } else {
      document.getElementById("nextBtn").classList.add("disabled");
    }

  });


// +++ functions +++ //

// Show/hide text fields
function showMy(theField) {
  document.getElementById(theField + "_wrapper").classList.remove("hidden");
  document.getElementById("submission_" + theField).disabled = false;
}
function hideMy(theField) {
  document.getElementById(theField + "_wrapper").classList.add("hidden");
  document.getElementById("submission_" + theField).disabled = true;
}


// show/hide error wrappers
function addError() {
  document.getElementById("t" + currentTab).classList.add("form-tab-error");
  document.getElementById("form_alert" + currentTab).classList.remove("hidden");
  document.getElementById("nextBtn").classList.add("disabled");
}
function removeError() {
  document.getElementById("t" + currentTab).classList.remove("form-tab-error");
  document.getElementById("form_alert" + currentTab).classList.add("hidden");
  document.getElementById("nextBtn").classList.remove("disabled");
}