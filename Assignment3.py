lines = []
baseCookies = []
newCookies = []
baseCookieToSegment = {}
baseSegmentToCookie = {}
newCookieToSegment = {}
newSegmentToCookie = {}
end = None




#def setDicts(file1, itNum):
#    pass



#'evaluator-integration-baseline.log'

def setDicts(fileName, iterNum):
    with open(fileName) as file:
        count = 0
        for line in file:
            count += 1
            print("count =",count)
            line = line.strip()

            # Check if our string is in the line
            if "evaluated: " not in line:
                continue
            splitLine = line.split("evaluated:", 1)[1]
            # get the cookie and get rid of the spaces in front and back
            cookie = splitLine.split("==>", 1)[0][1:-1]
            if (iterNum == 0):
                baseCookies.append(cookie)
            else:
                newCookies.append(cookie)
            segments = splitLine.split("==>", 1)[1]
            # print(splitLine)
            #print(cookie, segments)
            # Perform slicing on strings using ',' as a delimiter to be split from
            allSegs = sliceSegs(segments.split(","))
            if (iterNum == 0):
                baseCookieToSegment[cookie] = allSegs
                mapSegs(allSegs, cookie, iterNum)
            else:
                newCookieToSegment[cookie] = allSegs

            #print("allSegs=", allSegs)

            # lines.append(line) #storing everything in memory!
    return

def sliceSegs(allSegs):
    #If the length of the list is more than one we iterate through, otherwise
    #return the list right away
    if (len(allSegs) != 1):
        for count, val in enumerate(allSegs):
            if (count == 0):
                allSegs[count] = val[2:end]
            # If it is the last value, the ] needs to be removed from the back of the string
            elif len(allSegs) == count + 1:
                allSegs[count] = val[1:-1]
            else:  # Case for all segments that are not the first or last
                allSegs[count] = val[1:end]
    elif len(allSegs[0]) > 3: #If the cookie has one segment and it is not empty []
        allSegs[0] = allSegs[0][2:-1]
    else:
        allSegs[0] = allSegs[0][1:end]
    return allSegs

def mapSegs(segList, cookie, itNum):
    for seg in segList:
        key = seg
        if (itNum == 0):
            baseSegmentToCookie.setdefault(key,[])
            baseSegmentToCookie[key].append(cookie)
        else:
            newSegmentToCookie.setdefault(key,[])
            newSegmentToCookie[key].append(cookie)
    return


file1 = 'evaluator-integration-baseline.log'
file2 = 'evaluator-integration.log'

itNum = 0

# main method
print("start")
setDicts(file1,itNum)
print("done with file1")
itNum += 1
setDicts(file2,itNum)
print("done")
