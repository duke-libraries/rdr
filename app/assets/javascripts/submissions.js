// Script for submissions

var submitForm = false;
var currentTab = 0; // First tab is 0
showTab(currentTab); // Display the current tab

function showTab(n) {
  var x = document.getElementsByClassName("form-tab");
  x[n].style.display = "block";

  if (n == 0) {
    document.getElementById("prevBtn").style.display = "none";
  } else {
    document.getElementById("prevBtn").style.display = "inline";
  }

  // Change 'next' to 'submit' on last tab
  if (currentTab == 9) {
    document.getElementById("nextBtn").innerHTML =
      "<span class='sr-only'>Submit</span><span aria-hidden='true'>Submit &gt;&gt;</span>";
  }
}

function nextPrev(n) {
  var x = document.getElementsByClassName("form-tab");

  if (n == 1 && !validateForm()) {
    return false;
  }

  if ((n == 1 && submitForm == true) || (n == 1 && currentTab == 9)) {
    document.getElementById("new_submission").submit();
    return false;
  }

  x[currentTab].style.display = "none";

  // if previous button
  if (n == -1) {
    submitForm = false;
    document
      .getElementById("t" + currentTab)
      .classList.remove("form-tab-error");
    document.getElementById("form_alert" + currentTab).classList.add("hidden");
    document.getElementById("nextBtn").innerHTML =
      "<span class='sr-only'>Next</span><span aria-hidden='true'>&gt;&gt;</span>";
  }

  currentTab = currentTab + n;

  //console.log('current tab: ' + currentTab);

  showTab(currentTab);
}

function validateForm() {
  var x,
    y,
    i,
    j,
    valid = true;

  x = document.getElementsByClassName("form-tab");
  y = x[currentTab].getElementsByTagName("input");
  z = x[currentTab].getElementsByTagName("textarea");

  // Check every input field in the current tab:
  for (i = 0; i < y.length; i++) {
    // If it's a radio button
    if (y[i].type == "radio") {
      if (y[i].checked == true) {
        // Submit early for certain responses

        if (currentTab == 1 && y[i].value == "not ready") {
          submitForm = true;
        }

        if (currentTab == 2 && y[i].value == "yes") {
          submitForm = true;
        }

        if (currentTab == 3 && y[i].value == "no") {
          submitForm = true;
        }

        if (currentTab == 5 && y[i].value == "more than 10 GB") {
          submitForm = true;
        }

        if (currentTab == 5 && y[i].value == "more than 2.5 GB") {
          submitForm = true;
        }

        if (currentTab == 6 && y[i].value == "I do not agree") {
          submitForm = true;
        }

        // Implement skip logic

        if (currentTab == 4 && y[i].value == "no") {
          document.getElementById("screening-5a").classList.add("hidden");
          document.getElementById("screening-5b").classList.remove("hidden");
          document.getElementById("funded-size-1").disabled = false;
          document.getElementById("funded-size-2").disabled = false;
          document.getElementById("nonfunded-size-1").disabled = true;
          document.getElementById("nonfunded-size-2").disabled = true;
        }

        if (currentTab == 4 && y[i].value == "yes") {
          document.getElementById("screening-5a").classList.remove("hidden");
          document.getElementById("screening-5b").classList.add("hidden");
          document.getElementById("funded-size-1").disabled = true;
          document.getElementById("funded-size-2").disabled = true;
          document.getElementById("nonfunded-size-1").disabled = false;
          document.getElementById("nonfunded-size-2").disabled = false;
        }

        // Manually check text field inputs

        if (currentTab == 8 && y[i].value == "yes") {
          if (document.getElementById("submission_doi").value == "") {
            document
              .getElementById("submission_doi")
              .classList.add("text-area-empty");
            document
              .getElementById("t" + currentTab)
              .classList.add("form-tab-error");
            document
              .getElementById("form_alert" + currentTab)
              .classList.remove("hidden");
            valid = false;
            break;
          }

          if (document.getElementById("submission_doi").value != "") {
            document
              .getElementById("submission_doi")
              .classList.remove("text-area-empty");
          }
        }

        if (currentTab == 9 && y[i].value == "will not use cc0") {
          if (document.getElementById("submission_license").value == "") {
            document
              .getElementById("submission_license")
              .classList.add("text-area-empty");
            document
              .getElementById("t" + currentTab)
              .classList.add("form-tab-error");
            document
              .getElementById("form_alert" + currentTab)
              .classList.remove("hidden");
            valid = false;
            break;
          }

          if (document.getElementById("submission_license").value != "") {
            document
              .getElementById("submission_license")
              .classList.remove("text-area-empty");
          }
        }

        valid = true;

        document
          .getElementById("t" + currentTab)
          .classList.remove("form-tab-error");
        document
          .getElementById("form_alert" + currentTab)
          .classList.add("hidden");

        break;
      } else if (y[i].checked == false) {
        valid = false;
        document
          .getElementById("t" + currentTab)
          .classList.add("form-tab-error");
        document
          .getElementById("form_alert" + currentTab)
          .classList.remove("hidden");
      }
    }
  }

  // Loop through text areas
  for (j = 0; j < z.length; j++) {
    if (z[j].required) {
      if (z[j].value == "") {
        valid = false;
        z[j].classList.add("text-area-empty");
        document
          .getElementById("t" + currentTab)
          .classList.add("form-tab-error");
        document
          .getElementById("form_alert" + currentTab)
          .classList.remove("hidden");
      }

      if (z[j].value != "") {
        z[j].classList.remove("text-area-empty");
      }
    }
  }

  //if (valid) {
  // Do something
  //}

  return valid;
}

// Show/hide text fields

function showMy(theField) {
  document.getElementById(theField + "_wrapper").classList.remove("hidden");
  document.getElementById("submission_" + theField).disabled = false;
}

function hideMy(theField) {
  document.getElementById(theField + "_wrapper").classList.add("hidden");
  document.getElementById("submission_" + theField).disabled = true;
}
