The Dharma API [![Build Status](https://secure.travis-ci.org/tombh/dharma-api.png)](http://travis-ci.org/tombh/dharma-api)
==============

The Dharma API aims to be a single canonical source of all the dharma talks and teachers on the web.

<span class="talk_count"></span>

It does this by scraping dharma talk information from various sites and providing a RESTful interface, against which
you can make all kinds of powerful queries. It's endpoint is [dharma-api.com](http://dharma-api.com)

The code for this site is hosted on [Github](https://github.com/tombh/dharma-api) and can be contributed to by anyone.

It currently archives all the talks from;

- [dharmaseed.org](http://dharmaseed.org)
- [audiodharma.org](http://audiodharma.org)
- [forestsanghapublications.org](http://forestsanghapublications.org)
- [birken.ca](http://birken.ca/dhammatalks.html)

The API can be used to build apps such as [@busyanimal](http://twitter.com/busyanimal)'s [dharmasearch.com](http://dharmasearch.com)

## Dana ##

In order to use the API you will need an API key. But before you get one please bear in mind the nature of the media
available throught this API. All the talks are gathered from around the web and although all the hosts of the talks
permit their redistribution they do come with formal licensing agreements such as dharmaseesd.org's and audiodharma.org's
[Creative Common's License](http://creativecommons.org/licenses/by-nc-nd/3.0/).

I believe the essential thing to consider is the spirit of dana (generosity) that these talks are given in, they are given 
freely. However, the archivers and givers of these talks often seek modest donations to help them sustain the continued
availability of the dharma. Dig deep followers of the way!

## Requesting an API key ##

<div class="email_request" markdown="1">
You can request a key from;
<p>
	<a href="http://dharma-api.com/request_api_key?email=">http://dharma-api.com/request_api_key?email=</a>
</p>
followed by your email address. You will be emailed a valid key straight away.
</div>

## Using the API ##

To make any requests you must append your API key as follows;

	dharma-api.com/talks?api_key=1234567890abc

All responses are in JSON and you can get JSONp responses by using a callback param in the usual way;

	dharma-api.com/talks?api_key=1234567890abc&callback=functionName

NB. The server accepts Cross-Domain requests using CORS headers.

### Methods ###

There are 4 main methods

**/talks**


	metta: {
		total: 3550,
		results_per_page: 25,
		ordered_by: "date desc",
		loving_kindness: true
	},
	results: [
	{
		date: "2012-05-14",
		duration: 2576,
		id: 2218,
		license: "http://creativecommons.org/licenses/by-nc-nd/3.0/",
		permalink: "http://audiodharma.org/teacher/67/talk/3043/venue/IMC/20120514-Kevin_Griffin-IMC-angulimala.mp3",
		source: "http://audiodharma.org",
		speaker_id: 55,
		title: "Angulimala",
		venue: "Insight Meditation Centre, Redwood, California"
	} 

	...(lots more talks here)...



Note the metta data that lists information about the result. Pagination is discussed below.

The duration is in seconds and it is left up to the user to convert it.

The speaker can be accessed with the speaker_id like so `/speaker/55`

**/speakers**

	metta: {
		total: 360,
		results_per_page: 25,
		ordered_by: "id asc",
		loving_kindness: true
	},
	results: [
	{
		bio: "Lately, my own practice is moving more and more into the monastic world. As I teach out [...]",
		id: 1,
		name: "Mary Grace Orr",
		picture: "http://media.dharmaseed.org/uploads/photos/thumb_13589%20C%20Mary.jpg"
	}
	
	...(lots more speakers here)...

Note that this method doesn't list all the talks for a given speaker. You will need the `/speaker` methd for that.

**/talk/:id**

This method gives all the details for a specific talk _including_ all the details about the speaker.

	{
		date: "2012-05-15",
		description: "Being with things as they are and letting go are very difficult. The friendly and open heart support us in this work.",
		duration: 3032,
		id: 1,
		license: "http://creativecommons.org/licenses/by-nc-nd/3.0/",
		permalink: "http://dharmaseed.org/teacher/122/talk/16093/20120515-Mary_Grace_Orr-SR-how_does_the_heart_let_go.mp3",
		source: "http://dharmaseed.org",
		title: "How Does the Heart Let Go?",
		speaker: {
			bio: "Lately, my own practice is moving more and more into the monastic world. As I teach out [...]",
			id: 1,
			name: "Mary Grace Orr",
			picture: "http://media.dharmaseed.org/uploads/photos/thumb_13589%20C%20Mary.jpg"
		}
	}


**/speaker/:id**

This method gives all the details for a speaker _including_ all their talks.

	{
		bio: "As a young child growing up in Tibet, Anam Thubten was intent on [...]",
		id: 16,
		name: "Anam Thubten",
		picture: "http://media.dharmaseed.org/uploads/photos/thumb_atrofficial.jpg",
		website: "http://www.dharmata.org",
		talks: [
		{
			date: "2012-04-23",
			description: "Spirit Rock Meditation Center:  Monday and Wednesday Talks",
			duration: 3632,
			event: "Monday and Wednesday Talks",
			id: 55,
			license: "http://creativecommons.org/licenses/by-nc-nd/3.0/",
			permalink: "http://dharmaseed.org/teacher/335/talk/15976/20120423-Anam_Thubten-SR-impulse_to_freedom.mp3",
			source: "http://dharmaseed.org",
			speaker_id: 16,
			title: "Impulse To Freedom",
			venue: "Spirit Rock Meditation Center"
		}
		]
	}


### Extra params ###

The `/talks` and `/speakers` methods each take the following useful params;

**`search=`**

Searches all the text fields including permalinks for the given string.

**`order=`**  

Attempts to order the results by the given field. To use reverse order, place a `-` at the beginning of the field, eg;

	/talks?order=-duration

**`page=`**

When there are more than 25 (or the value specified by rpp) results per page you can paginate through by passing integers.

**`rpp=`**

The number of results to show per page.


## Adding more talks to the API ##

We're always looking for more sources of dharma talks, if you would like to see a new source then please do open a [feature 
request](https://github.com/tombh/dharma-api/issues). Or even better fork the code and write your own spider and submit a pull request.
It would add to the stability of the API if you can provide concise tests for your spider, tests that both cover the code and the
applicability to the ever changing HTML of the live site from which the talks are scraped.

You can get a good idea of what is needed to create a working spider by looking at the existing ones under the /spiders folder.

## License ##

This code is licensed under the GNU GPL, see LICENSE.txt