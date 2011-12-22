module KabcoilHelper
	def pagination_links_remote(paginator)
	  page_options = {:window_size => 3}
	  pagination_links_each(paginator, page_options) do |n|
		 options = {
			:url => {:action => 'list', :params => params.merge({:page => n})},
			:update => 'content',
			:before => "Element.show('spinner')",
			:success => "Element.hide('spinner')"
		 }
		 html_options = {:href => url_for(:action => 'list', :params => params.merge({:page => n})), :class => "pg"}
		 link_to_remote(n.to_s, options, html_options)
	  end
	end

	def sort_td_class_helper(field, cl="")
		case params[:sort]
		when field : "class='sortup #{cl}'"
		when field+"_reverse" : "class='sortdown #{cl}'"
		else "class='#{cl}'"
		end
	end

	def all_pages_link_helper(text, param)
	  key = param
	  key += "_reverse" if params[:sort] == param
	  options = {
			:url => {:action => 'list', :params => params.merge({:sort => key, :page => "-1"})},
			:update => 'content',
			:before => "Element.show('spinner')",
			:success => "Element.hide('spinner')"
	  }
	  html_options = {
		 :title => _("Sort by this field"),
		 :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => "-1"})),
		 :class => "pg"
	  }
	  link_to_remote(text, options, html_options)
	end

	def sort_link_helper(text, param)
	  key = param
	  key += "_reverse" if params[:sort] == param
	  options = {
			:url => {:action => 'list', :params => params.merge({:sort => key, :page => nil})},
			:update => 'content',
			:before => "Element.show('spinner')",
			:success => "Element.hide('spinner')"
	  }
	  html_options = {
		 :title => _("Sort by this field"),
		 :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => nil})
			)
	  }
	  link_to_remote(text, options, html_options)
	end
end
