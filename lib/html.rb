# home of everything html output related

def html_header
  html = <<-HTML
  <!DOCTYPE html>
  <html>
  <head>
  	<title>Plex missing episodes</title>

  	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css">
  	<style type="text/css" class="init"></style>
  	<script type="text/javascript" language="javascript" src="http://code.jquery.com/jquery-1.12.0.min.js"></script>
  	<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>
  	
    <script type="text/javascript" class="init">
      $(document).ready(function() {
  	    $('#episodes').DataTable( {
  		    "order": [[ 0, "asc" ]],
          "lengthMenu": [ [50, 100, -1], [50, 100, "All"] ]
  	      } );
       } );
  	</script>
       
  </head>
  <body>
  HTML
  puts html
end

def html_footer
  html = <<-HTML 
  </body>
  </html>
  HTML
  puts html
end

def html_table_start
  html = <<-HTML 
				<table id="episodes" class="display compact" cellspacing="0" width="100%">
					<thead>
						<tr>
							<th>Show</th>
							<th>Season</th>
							<th>Episode</th>
							<th>Air Date</th>
							<th>Links</th>
						</tr>
					</thead>
					<tfoot>
						<tr>
							<th>Show</th>
							<th>Season</th>
							<th>Episode</th>
							<th>Air Date</th>
							<th>Links</th>
							<th></th>
						</tr>
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

def html_table_row(show, season, episode, kat, bay)
  html = <<-HTML 
	<tr>
		<td>#{show}</td>
		<td>#{season}</td>
		<td>#{episode}</td>
		<td>n/a</td>
		<td><a target=\"blank\" href=\"#{kat}\">kat</a> | <a target=\"blank\" href=\"#{bay}\">bay</a></td>
	</tr>
  HTML
  puts html
end

# takes a Hash of HASH[SHOW][SEASON][EPISODE]
def html_table_content(episodes_missing)
  episodes_missing.keys.each do |show|
    episodes_missing[show].keys.each do |season|
      episodes_missing[show][season].keys.each do |episode|
        pair = show_index season, episode
        data = URI.escape(show + ' ' + pair)
        kat  = "https://kat.cr/usearch/#{data}%20category%3Atv/?field=seeders&sorder=desc"
        bay  = "http://thepiratebay.se/search/#{data}/0/7/200"
        html_table_row(show, season,episode, kat, bay)
      end
    end
  end
end

def html_create(episodes_missing)
  html_header
  html_table_start
  html_table_content episodes_missing  
  html_table_end
  html_footer
end