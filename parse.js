function fn$(e){return e.trim()}function fn1$(e){return pair[1][e]}function fn2$(e){return e.join(",")}function fn3$(e){return'"'+e+'"'}function fn4$(e){return e.join(",")}var fs,fsExtra,px,files,cat,idx,i$,len$,file,prefix,obj,stubs,data,count,j$,to$,i,time,k$,to1$,j,county,l$,to2$,k,index,value,ref$,list,times,lines,pairs,res$,counties,countynames,pair,headers,line;for(fs=require("fs"),fsExtra=require("fs-extra"),px=require("px"),fsExtra.mkdirsSync("csv/county/"),files=fs.readdirSync("raw/county/").map(function(e){return{src:"raw/county/"+e,des:("csv/county/"+e).replace(/\.px$/,".csv"),name:e}}),cat={},idx={},i$=0,len$=files.length;len$>i$;++i$)for(file=files[i$],prefix=file.name.substring(0,2),obj=new px(fs.readFileSync(file.src,"utf8")),stubs=obj.metadata.VALUES,data=obj.data,count=0,cat[prefix]||(cat[prefix]=["年度","縣市"]),cat[prefix]=cat[prefix].concat(stubs["指標"].map(fn$)),j$=0,to$=stubs["期間"].length;to$>j$;++j$)for(i=j$,time=stubs["期間"][i],k$=0,to1$=stubs["縣市"].length;to1$>k$;++k$)for(j=k$,county=stubs["縣市"][j],l$=0,to2$=stubs["指標"].length;to2$>l$;++l$)k=l$,index=stubs["指標"][k].trim(),count=j+stubs["縣市"].length*(i+k*stubs["期間"].length),value=data[count],isNaN(parseInt(value))&&(value="-"),((ref$=idx[index]||(idx[index]={}))[time]||(ref$[time]={}))[county]=value;fsExtra.mkdirsSync("csv/county/index"),list=[];for(index in idx){times=idx[index],lines=[],res$=[];for(time in times)counties=times[time],res$.push([time,counties]);pairs=res$,res$=[];for(county in pairs[0][1])res$.push(county);for(countynames=res$,lines.push(["年度"].concat(countynames)),i$=0,len$=pairs.length;len$>i$;++i$)pair=pairs[i$],lines.push([pair[0]].concat(countynames.map(fn1$)));fs.writeFileSync("csv/county/index/"+index+".csv",lines.map(fn2$).join("\n")),list.push(index)}fs.writeFileSync("csv/county/index/index.json",JSON.stringify(list.map(function(e){return e+".csv"}))),fsExtra.mkdirsSync("csv/county/category");for(prefix in cat){for(headers=cat[prefix],lines=[headers.map(fn3$)],i$=0,to$=stubs["期間"].length;to$>i$;++i$)for(i=i$,time=stubs["期間"][i],j$=0,to1$=stubs["縣市"].length;to1$>j$;++j$){for(j=j$,county=stubs["縣市"][j],line=[time,county],k$=2,to2$=headers.length;to2$>k$;++k$)k=k$,index=headers[k],line.push(idx[index][time][county]);lines.push(line)}fs.writeFileSync("csv/county/category/"+prefix+".csv",lines.map(fn4$).join("\n"))}