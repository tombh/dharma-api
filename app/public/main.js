$(document).ready(function(){
	
	// The Dharama API uses keys as no more than a basic mechanism for tracking users.
	// If a key is found to be the source of exploitative usage it will disabled.
	var key = 'db2c3fe9dcfa0dfca53682546abbbd9e';
	$.getJSON('/talks?api_key=' + key, function(response){
		var text = "<p>There are currently " + response.metta.total + " archived talks.</p>";
		$('.talk_count').html(text);
	});

	var
	form = '<form class="api_form">';
	form += '<input type="email" name="email" placeholder="Your email" />';
	form += '<input type="submit" value="Request API key" />';
	form += '</form>';
	$('.email_request').html(form);

	$('.api_form').submit(function(e){
		e.preventDefault();
		var email = $('.api_form input[name=email]').val();
		if(!email) return;
		$.getJSON('/request_api_key?email=' + email, function(response, status){
			if(status == 'success'){
				$('.email_request').hide().html('Your API key has just been sent to you :)').fadeIn();
			}else{
				$('.api_form').after('<em>Ouch, something went wrong, please try again</em>');
			}
			
		});
	});

});