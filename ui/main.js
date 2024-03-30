let remembercid = '';
let rememberSocietyMoney = '';
let rememberOldSocietyMoney = '';



$(".employeelistB").click(function(){
    $(".hirelistcontainer").slideUp();
    $(".societycontainer").slideUp();
    setTimeout(function() {
    $(".employeelistcontainer").slideDown('slow');
    $(".maincontainer").css('filter', 'none');
}, 600);
    return;
  })

  $(".recruitB").click(function(){
    $(".employeelistcontainer").slideUp();
    $(".societycontainer").slideUp();
    $(".promotelist").slideUp();
    $(".maincontainer").css('filter', 'none');
    setTimeout(function() {
    $(".hirelistcontainer").slideDown('slow');
}, 600);
    return;
  })

  $(".societymoneyB").click(function(){
    $(".maincontainer").css('filter', 'blur(4px)');
    $(".maincontainer").css('pointer-events', 'none');
      $(".societycontainer").slideDown();
    return;
  })

  $(".societyClose").click(function(){
    $(".maincontainer").css('filter', 'none');
    $(".maincontainer").css('pointer-events', 'all');
      $(".societycontainer").slideUp();
      document.querySelector('#amountnumber').value = "";
    return;
  })

  document.onkeyup = function (data) {
    if (data.which == 27) {
        $(".maincontainer").slideUp();
        $(".promotelist").slideUp();
        $(".societycontainer").slideUp();
        $(".maincontainer").css('filter', 'none');
        $(".maincontainer").css('pointer-events', 'all');
      $.post("https://sq-bossmenu/hide", JSON.stringify({}));
      return;
    }}

    $(document).on('click', '.promoteB', function(){
       $(".promotelist").slideDown();
       $(".maincontainer").css('filter', 'blur(4px)');
       $(".maincontainer").css('pointer-events', 'none');
       remembercid = $(this).closest('.UserList').attr('data-citizenid');
       document.querySelector('.promotelisttext').textContent = $(this).closest('.UserList').attr('data-fullname');
      return;
    })


    $(document).on('click', '.hireB', function(){
      $.post("https://sq-bossmenu/addemployee", JSON.stringify({
        id: $(this).closest('.UserListHire').attr('data-citizenid'),
      }));
      return;
    })

    $(".promoteBclose").click(function(){
        $(".promotelist").slideUp();
        $(".maincontainer").css('filter', 'none');
        $(".maincontainer").css('pointer-events', 'all');
        document.querySelector(".labelscontainer").scrollTop = 0;
      return;
    })

    $(".bossinvB").click(function(){
      $(".maincontainer").slideUp();
      $(".societycontainer").slideUp();
      $(".promotelist").slideUp();
        $(".maincontainer").css('filter', 'none');
      $.post("https://sq-bossmenu/openbossinv", JSON.stringify({}));
      return;
    })

    $(document).on('click', '.label', function(){
      $(".promotelist").slideUp();
      $(".maincontainer").css('filter', 'none');
      $(".maincontainer").css('pointer-events', 'all');
      document.querySelector(".labelscontainer").scrollTop = 0;
      $.post("https://sq-bossmenu/promoteemployee", JSON.stringify({
        cid: remembercid,
        gradelevel: $(this).closest('.label').attr('data-Gnumber'),
      }));
      return;
    })

    $(document).on('click', '.fireB', function(){
      var citizenId = $(this).closest('.UserList').attr('data-citizenid');
      $.post("https://sq-bossmenu/fireemployee", JSON.stringify({
        cid: citizenId,
      }));
      return;
    })

    $(document).on('click', '.hstextB', function(){
      $.post("https://sq-bossmenu/refresh", JSON.stringify({}));
      return;
    })

    $(document).on('click', '.withdrawB', function(){
      rememberOldSocietyMoney = rememberSocietyMoney 
      $.post("https://sq-bossmenu/withdraw", JSON.stringify({
        amount: document.querySelector('#amountnumber').value,
      }));
      $.post("https://sq-bossmenu/refresh", JSON.stringify({}));
      document.querySelector('#amountnumber').value = "";
      setTimeout(function() {
        if(rememberOldSocietyMoney != rememberSocietyMoney) {
          document.querySelector('.societymoneyNumber').style.color = "#ff0000";
          setTimeout(function() {
            document.querySelector('.societymoneyNumber').style.color = "white";
        }, 1000);
        }
      }, 200);
      return;
    })

    $(document).on('click', '.depositB', function(){
      rememberOldSocietyMoney = rememberSocietyMoney 
      $.post("https://sq-bossmenu/deposit", JSON.stringify({
        amount: document.querySelector('#amountnumber').value,
      }));
      $.post("https://sq-bossmenu/refresh", JSON.stringify({}));
      document.querySelector('#amountnumber').value = "";
      setTimeout(function() {
      if(rememberOldSocietyMoney != rememberSocietyMoney) {
        document.querySelector('.societymoneyNumber').style.color = "#00ff0d";
        setTimeout(function() {
          document.querySelector('.societymoneyNumber').style.color = "white";
      }, 1000);
      }
    }, 200);
      return;
    })




    window.addEventListener("message", function(event) { 
      const item = event.data
      if(item.type === 'show') {
          $(".maincontainer").slideDown();
        } else if(item.type === 'refresh') {
          $(".hirelistcontainer").slideUp();
          setTimeout(function() {
          $(".hirelistcontainer").slideDown();
        }, 500);

} else if(item.type === 'update') {
  $('.listTable').empty();
    let thesocietyamount = item.societyamount
    document.querySelector('.societymoneyNumber').textContent = thesocietyamount.toLocaleString() + '$';
    rememberSocietyMoney = thesocietyamount;
    document.querySelector('.subnametext2').textContent = item.Pfullname;
    document.querySelector('.subbosstext2').textContent = item.Pjob.charAt(0).toUpperCase() + item.Pjob.slice(1) + ' Boss Menu';
  
     /* var Employees = item.Employees.sort((a, b) => { */
     var sortedEmployees = item.Employees.sort((a, b) => {
        return b.gradelevel - a.gradelevel;
      });
  
    /* for (var i = 0; i < item.Employees.length; i++) { */
    for (var i = 0; i < sortedEmployees.length; i++) {
     /* var player = item.Employees[i]; */
     var player = sortedEmployees[i];
     
       if(item.Pjob == 'police' || item.Pjob == 'ambulance') {
        newRow = 
        `                <tr class="UserList" data-citizenid="${player.cid}" data-fullname="${player.name}">
        <td><img src="${player.img}" alt=""> ${player.name}</td>
        <td>${player.cid}</td>
        <td>${player.gradename}</td>
        <td class="Status${player.online}">${player.online}</td>
        <td class="promoteB">Promote</td>
        <td class="fireB">Fire</td>
    </tr>`
    } else {
      newRow = 
      `                <tr class="UserList" data-citizenid="${player.cid}" data-fullname="${player.name}">
      <td><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg" alt=""> ${player.name}</td>
      <td>${player.cid}</td>
      <td>${player.gradename}</td>
      <td class="Status${player.online}">${player.online}</td>
      <td class="promoteB">Promote</td>
      <td class="fireB">Fire</td>
  </tr>`
    }

  
         $('.listTable').append(newRow);
    }
  } else if(item.type === 'updategradesmenu') {
    $('.labelscontainer').empty();
  
    /* var Employees = item.Employees.sort((a, b) => { */
    var sortedGradesmenu = item.Gradesmenu.sort((a, b) => {
       return b.gradenumber - a.gradenumber;
     });
  
   /* for (var i = 0; i < item.Gradesmenu.length; i++) { */
   for (var i = 0; i < sortedGradesmenu.length; i++) {
    /* var player = item.Gradesmenu[i]; */
    var player2 = sortedGradesmenu[i];
    
  if(player2.isboss == 'false') {
       newRow2 = 
       `
     <div class="label" data-Gnumber="${player2.gradenumber}">${player2.gradename}</div>
     `
  } else {
    newRow2 = 
    `
    <div class="label isboss" data-Gnumber="${player2.gradenumber}">${player2.gradename}</div>
    `
  }
        $('.labelscontainer').append(newRow2);
   }
  } else if(item.type === 'updatehirelist') {
    $('.listTableHire').empty();
  
     /* var Employees = item.Employees.sort((a, b) => { */
     var sortedClosestPlayers = item.ClosestPlayers.sort((a, b) => {
        return a.id - b.id;
      });
  
    /* for (var i = 0; i < item.Employees.length; i++) { */
    for (var i = 0; i < sortedClosestPlayers.length; i++) {
     /* var player = item.Employees[i]; */
     var player3 = sortedClosestPlayers[i];
       
       if(item.citizenid == player3.cid) {
        newRow3 = 
        `                     <tr class="UserListHire" data-citizenid="${player3.cid}">
        <td><i class="fa-solid fa-id-badge"></i> ${player3.id}</td>
        <td>${player3.name}</td>
        <td>${player3.cid}</td>
        <td class="hireB">Hire</td>
    </tr>`
       }
  
         $('.listTableHire').append(newRow3);
    }
  }
  })
