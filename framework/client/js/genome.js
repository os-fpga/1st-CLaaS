
function readURLOne(input) {
    if (input.files && input.files[0]) {
  
      var reader = new FileReader();
  
      reader.onload = function(e) {
        $('.image-upload-wrap-one').hide();
  
        $('#file-upload-image-one').attr('src', e.target.result);
        $('#file-upload-content-one').show();
        $('#image-title-one').html(input.files[0].name);

        console.log(reader.result)

        
      };
  
      // reader.readAsDataURL(input.files[0]);
      reader.readAsText(input.files[0]);

    } else {
      removeUploadOne();
    }
  }
  
  function removeUploadOne() {
    $('.file-upload-input-one').replaceWith($('.file-upload-input-one').clone());
    $('#file-upload-content-one').hide();
    $('.image-upload-wrap-one').show();
  }
  $('.image-upload-wrap-one').bind('dragover', function () {
          $('.image-upload-wrap-one').addClass('image-dropping-one');
      });
      $('.image-upload-wrap-one').bind('dragleave', function () {
         $('.image-upload-wrap-one').removeClass('image-dropping-one');
  });


  function readURLTwo(input) {
    if (input.files && input.files[0]) {
  
      var reader = new FileReader();
  
      reader.onload = function(e) {
        $('.image-upload-wrap-two').hide();
  
        $('#file-upload-image-two').attr('src', e.target.result);
        $('#file-upload-content-two').show();
        $('#image-title-two').html(input.files[0].name);

        console.log(reader.result)
      };
  
      // reader.readAsDataURL(input.files[0]);
      reader.readAsText(input.files[0]);

    } else {
      removeUploadTwo();
    }
  }
  
  function removeUploadTwo() {
    $('.file-upload-input-two').replaceWith($('.file-upload-input-two').clone());
    $('#file-upload-content-two').hide();
    $('.image-upload-wrap-two').show();
  }
  $('.image-upload-wrap-two').bind('dragover', function () {
          $('.image-upload-wrap-two').addClass('image-dropping-two');
      });
      $('.image-upload-wrap-two').bind('dragleave', function () {
          $('.image-upload-wrap-two').removeClass('image-dropping-two');
  });
  