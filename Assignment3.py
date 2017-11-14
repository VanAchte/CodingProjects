import sys

lines = []
baseCookies = []
newCookies = []
baseCookieToSegment = {}
baseSegmentToCookie = {}
newCookieToSegment = {}
newSegmentToCookie = {}
end = None


def setDicts(fileName, iterNum):
    with open(fileName) as file:
        count = 0
        for line in file:
            count += 1
            #print("count =",count)
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
                mapSegs(allSegs, cookie, iterNum)

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



# main method
file1 = ''
file2 = ''
if len(sys.argv) > 2:
    file1 = sys.argv[1]
    file2 = sys.argv[2]
else:
    file1 = 'evaluator-integration-baseline.log'
    file2 = 'evaluator-integration.log'
    #file1 = 'baselineSmall.log'
    #file2 = 'postFile.log'



itNum = 0

print("start")
setDicts(file1,itNum)
print("done with file1")
itNum = 1
setDicts(file2,itNum)
print("done with file2")

numSegs = 0
missCookies = 0
addedCookies = 0

for key in baseSegmentToCookie.iterkeys():
    #print "key1=",key
    if key == "[]":
        continue
    #print "key=",key

    numSegs += 1
    # If key is empty, we do not count it as a segment

    if key in newSegmentToCookie:
        baseSet = set(baseSegmentToCookie.get(key))
        newSet = set(newSegmentToCookie.get(key))
        diff = newSet.difference(baseSet)
        if len(diff) > 0:
            addedCookies += 1
        #print "baseSet=",baseSet
        #print "newSet=",newSet
        #print not newSet.issuperset(baseSet)
        if not newSet.issuperset(baseSet):
            missCookies += 1
    else:
        missCookies += 1


numCookies = 0
missSegs = 0
addedSegs = 0
for key in baseCookieToSegment.iterkeys():
   #print "key1=",key
    # if key == "[]":
    #     continue
    #print "key=",key

    numCookies += 1

    # If key is empty, we do not count it as a segment

    if key in newCookieToSegment:
        baseSet2 = set(baseCookieToSegment.get(key))
        newSet2 = set(newCookieToSegment.get(key))
        diff = newSet2.difference(baseSet2)
        if len(diff) > 0:
            addedSegs += 1
        #print "\tbaseSet=",baseSet2
        #print "\tnewSet=",newSet2
        #print "\tdiff=", diff
        #print not newSet2.issuperset(baseSet2)
        if not newSet2.issuperset(baseSet2):
            missSegs += 1
    else:
        missSegs += 1



       #print "diff=", diff
print "Segments with added cookies:", addedCookies, "/", numSegs
print "Segments with missing cookies:", missCookies, "/", numSegs

print "Cookies in extra segments:", addedSegs, "/", numCookies
print "Cookies omitted from segments:", missSegs, "/", numCookies

# print "numCookies=", numCookies
# print "missSegs=", missSegs
# print "addedSegs=", addedSegs   

# print "numSegs=", numSegs


# print ("missCookies =",missCookies,"/",counter)
# print ("number of segments =", counter)
# print ("number of cookies =", counter2)
# print("addedCookies=", addedCookies)
print "done"
#for key in sorted(newSegmentToCookie.iterkeys()):
 #  print "key2=",key

