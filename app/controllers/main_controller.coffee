exports.home = (req,res)->
	res.render "#{CT_Static}/main/index.jade",{
		pretty:true
	}