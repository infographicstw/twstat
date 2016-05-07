angular.module \twstat, <[]>
  ..controller \twstatList,
  <[$scope $http]> ++
  ($scope, $http) ->
    $scope.blah = 123
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
    box = $scope.items.getBoundingClientRect!
    $($scope.items).css height: "#{window.innerHeight - box.top - 40}px"
    $scope.vizs = document.getElementById(\vizs)
    $scope.limitscroll $scope.vizs
    box = $scope.vizs.getBoundingClientRect!
    $($scope.vizs).css height: "#{window.innerHeight - box.top - 40}px"
    $scope.update = (csv) ->
      d3.csv "csv/county/index/#{csv.name}.csv", (d) -> $scope.$apply ->
        csv.data = d
        csv.svg = d3.select(\#vizs).append \svg
        csv.svg.attr { width: \100%, height: \200px}
        box = csv.svg.0.0.getBoundingClientRect!
        {width,height} = box{width,height}
        csv.svg.attr { viewBox: "0 0 #width #height"}
        line = d3.svg.line!
        console.log d



    $scope.toggle = (csv) ->
      csv.active=!!!csv.active
      if !csv.data => $scope.update csv
