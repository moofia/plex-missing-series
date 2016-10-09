# home of everything html output related

def html_data_table_init
  html = <<-HTML
  <script type="text/javascript" class="init">
    $(document).ready(function() {
	    $('#episodes').DataTable( {
		    "order": [[ 0, "asc" ]],
        "lengthMenu": [ [50, 100, -1], [50, 100, "All"] ]
	      } );
     } );
	</script>
  HTML
  html
end

def html_data_table_init_grouped
  html = <<-HTML
  <script type="text/javascript" class="init">
  $(document).ready(function() {
      var table = $('#episodes').DataTable({
          "columnDefs": [
              { "visible": false, "targets": 0 }
          ],
		    "order": [[ 0, "asc" ]],
        "lengthMenu": [ [50, 100, -1], [50, 100, "All"] ],
          "drawCallback": function ( settings ) {
              var api = this.api();
              var rows = api.rows( {page:'current'} ).nodes();
              var last=null;

              api.column(0, {page:'current'} ).data().each( function ( group, i ) {
                  if ( last !== group ) {
                      $(rows).eq( i ).before(
                          '<tr class="group"><td class="bg-primary"colspan="7">'+group+'</td></tr>'
                      );

                      last = group;
                  }
              } );
          }
      } );

      // Order by the grouping
      $('#episodes tbody').on( 'click', 'tr.group', function () {
          var currentOrder = table.order()[0];
          if ( currentOrder[0] === 0 && currentOrder[1] === 'asc' ) {
              table.order( [ 0, 'desc' ] ).draw();
          }
          else {
              table.order( [ 0, 'asc' ] ).draw();
          }
      } );
  } );

	</script>
  HTML
  html
end

def html_header
  html = <<-HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
  
    <!-- DataTables -->
  	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css">
  	<script type="text/javascript" language="javascript" src="http://code.jquery.com/jquery-1.12.0.min.js"></script>
  	<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>
  	
    <!-- Bootstrap -->
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">
    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
    

    #{html_data_table_init}
  </head>
  <body>
 	<title>Plex missing episodes</title>

  <div class="container-fluid">
  	<div class="row">
  		<div class="col-md-12">
  <h1>PLEX<small>missing episodes</small></h1>
  <br>
  <br>
  
  HTML
  puts html
end

def html_footer
  html = <<-HTML 
  </div>
  </div>
  </div>
  </body>
  </html>
  HTML
  puts html
end

def html_table_labels
    html = <<-HTML 
	          <tr>
	          	<th>Show</th>
	          	<th>Name</th>
	          	<th>Episode</th>
	          	<th>Air Date</th>
	          	<th>Status</th>
	          	<th>Genre</th>
	          	<th>Links</th>
	          </tr>
  HTML
  html
end

def html_table_start
  html = <<-HTML 
				<table id="episodes" class="display compact" cellspacing="0" width="100%">
					<thead>
            #{html_table_labels}
					</thead>
					<tfoot>
            #{html_table_labels}
					</tfoot>
					<tbody>
  HTML
  puts html
end

def html_table_end
  html = <<-HTML 
					</tbody>
				</table>
  HTML
  puts html
end

def html_table_row(show, season, episode, eztv, bay, rarbg, nzbplanet)
  
  url_imdb = 'http://www.imdb.com/title/' + $thetvdb.episodes[show]['imdb_id']
  url_thetvdb = 'http://thetvdb.com/?tab=series&id=' + $thetvdb.episodes[show]['id']
  
  html = <<-HTML 
	<tr>
		<td class="col-md-2">#{show}</td>
		<td class="col-md-2">#{$thetvdb.episodes[show]['episodes'][season][episode]['name']}</td>
		<td>#{show_index season, episode}</td>
		<td class="col-md-1">#{$thetvdb.episodes[show]['episodes'][season][episode]['first_aired']}</td>
		<td class="col-md-1">#{$thetvdb.episodes[show]['status']}</td>
		<td class="col-md-2">#{$thetvdb.episodes[show]['genre']}</td>
		<td class="col-md-2"><a target=\"blank\" href=\"#{url_thetvdb}\">TheTVDB</a> | <a target=\"blank\" href=\"#{url_imdb}\">IMDb</a> 
      | <a target=\"blank\" href=\"#{rarbg}\">rarbg</a> 
      | <a target=\"blank\" href=\"#{eztv}\">eztv</a> 
      | <a target=\"blank\" href=\"#{bay}\">bay</a>
      | <a target=\"blank\" href=\"#{nzbplanet}\">nzbplanet</a>
    </td>
	</tr>
  HTML
  puts html
end

# takes a Hash of HASH[SHOW][SEASON][EPISODE]
def html_table_content
  $plex.episodes_missing.keys.each do |show|
    $plex.episodes_missing[show].keys.each do |season|
      $plex.episodes_missing[show][season].keys.each do |episode|
        pair = show_index season, episode
        data = URI.escape(show + ' ' + pair)
        eztv   = "https://eztv.ag/search/#{data}"
        rarbg  = "https://rarbg.to/torrents.php?category=18;41&search=#{data}&order=seeders&by=DESC"
        bay    = "http://thepiratebay.se/search/#{data}/0/7/200"
        nzbplanet = "http://nzbplanet.net/search/#{data}"
        html_table_row(show, season,episode, eztv, bay, rarbg, nzbplanet)
      end
    end
  end
end

def html_create
  html_header
  html_table_start
  html_table_content  
  html_table_end
  html_footer
end