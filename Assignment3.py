lines = []

baseCookieToSegment = {}
baseSegmentToCookie = {}
newCookieToSegment = {}
newSegmentToCookie = {}
end = None

file1 = 'evaluator-integration-baseline.log'
file2 = 'evaluator-integration.log'

itNum = 0


#def setDicts(file1, itNum):
#    pass



#'evaluator-integration-baseline.log'

def setDicts(fileName, iterNum):
    with open(fileName) as file:
        count = 0
        for line in file:
            line = line.strip()  # or some other preprocessing

            # Check if our string is in the line
            if "evaluated: " not in line:
                continue
            splitLine = line.split("evaluated:", 1)[1]
            # get the cookie and get rid of the spaces in front and back
            cookie = splitLine.split("==>", 1)[0][1:-1]
            # cookie = cookie[1:-1]
            segments = splitLine.split("==>", 1)[1]
            # print(splitLine)
            print(cookie, segments)
            # Perform slicing on strings using ',' as a delimiter to be split from
            allSegs = sliceSegs(segments.split(","))
            if (iterNum == 0):
                baseCookieToSegment[cookie] = allSegs
            else:
                newCookieToSegment[cookie] = allSegs

            print("allSegs=", allSegs)

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


setDicts(file1,itNum)
itNum += 1
setDicts(file2,itNum)