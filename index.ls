angular.module \twstat, <[]>
  ..controller \twstatList,
  <[$scope $http]> ++
  ($scope, $http) ->
    $scope.vizs = document.getElementById \vizs
    $scope.pal = d3.scale.category20!
    $scope.city5 = <[高雄市 臺北市 臺中市 臺南市 新北市]>
    d3.select \div.legends .selectAll \div.legend .data $scope.city5
      ..enter!append \div .attr class: \legend
        .each ->
          node = d3.select(@)
          node.append \div .attr {class: \mark} .style background: -> $scope.pal(it)
          node.append \span .text -> it
    $http do
      url: \csv/county/index/index.json
      method: \GET
    .success (d) -> 
      $scope.csvs = d.map(->{name: it.replace(/\.csv$/, "")})

    $scope.limitscroll = (node) ->
      prevent = (e) ->
        e.stopPropagation!
        e.preventDefault!
        e.cancelBubble = true
        e.returnValue = false
        return false
      node.addEventListener 'mousewheel', (e) ->
        # http://stackoverflow.com/questions/5802467/prevent-scrolling-of-parent-element
        box = @getBoundingClientRect!
        height = box.height
        scroll = height: @scrollHeight, top: @scrollTop
        if scroll.height <= height => return
        delta = e.deltaY
        do-prevent = false
        on-agent = false
        if e.target and (e.target.id == \field-agent or e.target.parentNode.id == \field-agent) =>
          [on-agent,do-prevent] = [true,true]
        if on-agent =>
          $(@).scrollTop scroll.top + e.deltaY
        else if (-e.deltaY > scroll.top) =>
          $(@).scrollTop 0
          do-prevent = true
        else if (e.deltaY > 0 and (scroll.height - height - scroll.top) <= 0) =>
          do-prevent = true
        return if do-prevent => prevent e else undefined
    $scope.items = document.getElementById(\items)
    $scope.limitscroll $scope.items
    $scope.mobile = if window.innerWidth < 640 => true else false
    box = $scope.items.getBoundingClientRect!
    boxheight = window.innerHeight - box.top - 120
    if $scope.mobile => boxheight = 240
    $scope.yaxisWidth = (if $scope.mobile => 30 else 100)
    $($scope.items).css height: "#{boxheight}px"
    $scope.vizs = document.getElementById(\vizs)
    $scope.limitscroll $scope.vizs
    box = $scope.vizs.getBoundingClientRect!
    boxheight = window.innerHeight - box.top - 120
    if $scope.mobile => boxheight = 240
    $($scope.vizs).css height: "#{boxheight}px"
    $scope.update = (csv) ->
      d3.csv "csv/county/index/#{csv.name}.csv", (d) -> $scope.$apply ->
        csv.svg = d3.select(\#vizs).append \svg
        csv.svg.attr { width: \100%, height: \200px}
        box = csv.svg.0.0.getBoundingClientRect!
        {width,height} = box{width,height}
        csv.svg.attr { viewBox: "0 0 #width #height", opacity: 1}
        csv.data = d
        csv.data.forEach (d) -> for k,v of d => 
          d[k] = if isNaN(parseFloat(d[k])) => 0 else parseFloat(d[k])
        csv.keys = [k for k,v of csv.data.0].filter(->it!=\年度)
        csv.yearrange = d3.extent(csv.data.map(->parseInt(it["年度"])))

        csv.valuerange = d3.extent(csv.data
          .map (d) -> $scope.city5.map(->d[it])
          .reduce(((a,b) -> a ++ b ), [])
        )
        csv.parsed = csv.keys.map (k) -> {name: k, data: csv.data.map(->
          value = parseFloat(it[k])
          if isNaN(value) => value = 0
          { year: it[\年度], value }
        )}
        csv.svg.append("text").text(csv.name).attr({
          class: "title"
          transform: "translate(#{width / 2},190)"
          "font-size": "0.9em"
          "font-weight": "900"
          "text-anchor": "middle"
          "dominant-baseline": "central"
        })
        csv.xaxis-group = csv.svg.append \g .attr class: "axis horizontal"
        csv.yaxis-group = csv.svg.append \g .attr class: "axis vertical"
        csv.yscale = d3.scale.linear!domain csv.valuerange .range [160,10]
        csv.xscale = d3.scale.linear!domain csv.yearrange .range [$scope.yaxisWidth,width - 30]
        csv.xaxis = d3.svg.axis!orient \bottom .scale csv.xscale .ticks (if $scope.mobile => 4 else 10)
        csv.yaxis = d3.svg.axis!orient \left .scale csv.yscale .ticks 4
        csv.xaxis-group.call csv.xaxis
        csv.yaxis-group.call csv.yaxis
        csv.xaxis-group.attr transform: "translate(0,160)"
        csv.yaxis-group.attr transform: "translate(#{$scope.yaxisWidth},0)"
        csv.line = d3.svg.line!
          .x -> csv.xscale(it.year)
          .y -> csv.yscale(it.value)
        console.log csv.parsed
        csv.svg.selectAll \path.data .data csv.parsed.filter(->$scope.city5.indexOf(it.name)>=0)
          ..enter!append \path .attr do
            class: \data
            d: -> csv.line it.data
            stroke: -> $scope.pal(it.name)
            "stroke-width": 1
            fill: \none
          ..exit!remove!
        $scope.scrollto csv

    $scope.scrollto = (csv) ->
      box = csv.svg.0.0.getBoundingClientRect!
      $scope.vizs.scrollTop = box.top

    $scope.toggle = (csv) ->
      csv.active=!!!csv.active
      if !csv.data => $scope.update csv
      else =>
        setTimeout (->
          if csv.active =>
            csv.svg.attr opacity: 1
            $scope.vizs.appendChild(csv.svg.0.0)
            $scope.scrollto csv
          else => 
            csv.svg.transition!
              .attr { opacity: 0 }
              .each \end -> $scope.vizs.removeChild(csv.svg.0.0)
        ), 0
      $scope.actives = $scope.csvs.filter -> it.active
