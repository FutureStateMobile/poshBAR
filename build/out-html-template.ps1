@"
<!DOCTYPE html>
<html lang="en">
	<head>
		<title>$moduleName Documentation</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.4/css/bootstrap.min.css" rel="stylesheet" charset="utf-8">
		<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
		<!--[if lt IE 9]>
			<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
			<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
		<![endif]-->
		<style>
			.navbar-nav {
				height:100%;
				overflow-y: auto;

			}
			/* make sidebar nav vertical */ 
			@media (min-width: 768px) {
			  .sidebar-nav .navbar .navbar-collapse {
				padding: 0;
				max-height: none;
			  }
			  .sidebar-nav .navbar ul {
				float: none;
			  }
			  .sidebar-nav .navbar ul:not {
				display: block;

			  }
			  .sidebar-nav .navbar li {
				float: none;
				display: block;
			  }
			  .sidebar-nav .navbar li a {
				padding-top: 12px;
				padding-bottom: 12px;
			  }
			}

			@media (min-width: 992px) {
			  .navbar {
				  width: 300px;
			  }
			}

			@media (min-width: 768px) {
			  .navbar {
				  width: 300px;
			  }
			}
			@media (min-width: 1200px) {
			  .navbar {
				  width: 300px;
			  }
			}

			.sidebar-nav .navbar-header{ float: none; }
		</style>

	</head>
	<body>
    <div class="container-fluid">
		<div class="row">
        	<div class="col-xs-12"><h1>$moduleName</h1></div>
        </div>    
		<div class="row">
          <div class="col-sm-3">
            <div class="sidebar-nav">
              <div class="navbar navbar-default" role="navigation">
                <div class="navbar-header">
                  <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".sidebar-navbar-collapse">
                    <span class="sr-only">Toggle</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                  </button>
                  <span class="visible-xs navbar-brand">click menu to open</span>
                </div>
                <div class="navbar-collapse collapse sidebar-navbar-collapse">
                  <ul class="nav navbar-nav">
"@
$progress = 0
$commandsHelp | %  {
	Update-Progress $_.Name 'Navigation'
	$progress++
"					<li class=`"nav-menu`"><a href=`"#$($_.Name)`">$($_.Name)</a></li>"
}
@'
                  </ul>
                </div><!--/.nav-collapse -->
              </div>
            </div>
          </div>
          <div class="col-sm-9">
'@
$progress = 0
$commandsHelp | % {
	Update-Progress $_.Name 'Documentation'
	$progress++
@"
				<div id=`"$(FixString($_.Name))`" class="toggle_container">
					<div class="page-header">
						<h1>$(FixString($_.Name))</h1>
"@
	$syn = FixString($_.synopsis)
    if(!($syn).StartsWith($(FixString($_.Name)))){@"
						<p class="lead">$syn</p>
"@
	}
@"
					</div>
				    <div class=`"row`">
"@
	if (!($_.syntax | Out-String ).Trim().Contains('syntaxItem')) {@"
						<div class=`"col-md-12`">
							<h2> Syntax </h2>
							<pre>
<code>$(FixString($_.syntax | out-string))</code></pre>
						</div>
"@
	}
    if($_.parameters.parameter.Count -gt 0){
@"
						<div class=`"col-md-12`">
							<h2> Parameters </h2>
							<table class="table table-striped table-bordered table-condensed">
								<thead>
									<tr>
										<th>Name</th>
										<th>Description</th>
										<th>Required?</th>
										<th>Pipeline Input</th>
										<th>Default Value</th>
									</tr>
								</thead>
								<tbody>
"@
        foreach($param in $_.parameters.parameter){
@"
									<tr>
										<td>$(FixString($param.Name))</td>
										<td>$(FixString(($param.Description  | out-string).Trim()))</td>
										<td>$(FixString($param.Required))</td>
										<td>$(FixString($param.PipelineInput))</td>
										<td>$(FixString($param.DefaultValue))</td>
									</tr>
"@
        }
@"
								</tbody>
							</table>
						</div>				
"@
    }
    if (($_.inputTypes | Out-String ).Trim().Length -gt 0) {
@"
						<div class=`"col-md-12`">
					        <h2> Input Type </h2>
					        <div>$(FixString($_.inputTypes  | out-string))</div>
					    </div>
"@
	}
    if (($_.returnValues | Out-String ).Trim().Length -gt 0) {
@"
						<div class=`"col-md-12`">
							<h2> Return Values </h2>
							<div>$(FixString($_.returnValues  | out-string))</div>
						</div>
"@
	}
    if (($_.alertSet | Out-String ).Trim().Length -gt 0) {
@"
						<div class=`"col-md-12`">
							<h2> Notes </h2>
							<div>$(FixString($_.alertSet  | out-string -Width 2000).Trim())</div>
						</div>
"@
	}
	if(($_.examples | Out-String).Trim().Length -gt 0) {
@"
						<div class=`"col-md-12`">
							<h2> Examples </h2>
							<hr>
"@
		foreach($example in $_.examples.example){
@"
							<h3>$(FixString($example.title.Trim(('-',' '))))</h3>
							<pre>$(FixString($example.code | out-string ).Trim())</pre>
							<div>$(FixString($example.remarks | out-string -Width 2000).Trim())</div>
"@
		}
@"
						</div>
"@
	}
@"
					</div>
				</div>
"@
}
@'
		</div>
	</div>
	</div>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js" ></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.4/js/bootstrap.min.js" charset="utf-8"></script>
	<script>
		$(document).ready(function() {
			$(".toggle_container").hide();
			var previousId;
		    if(location.hash) {
		        var id = location.hash.slice(1);    //Get rid of the # mark
		        var elementToShow = $("#" + id);    //Save local reference
		        if(elementToShow.length) {                   //Check if the element exists
		            elementToShow.slideToggle('fast');       //Show the element
		            elementToShow.addClass("check_list_selected");    //Add class to element (the link)
		        }
		        previousId = id;
		    }

			$('.nav-menu a').click(function() {
				$('.toggle_container').hide();                 // Hide all
				var elem = $(this).prop("hash");
				$(elem).toggle('fast');   						// Show HREF/to/ID one
				history.pushState({}, '', $(this).attr("href"));
				window.scrollTo(0, 0);
				return false;
			});

		});
	</script>
	</body>
</html>
'@