#
# Copyright (c) 2015-2016 by The Board of Trustees of the Leland
# Stanford Junior University.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
#  Author: Lavanya Jose (lavanyaj@cs.stanford.edu)
#
#

import random
import numpy as np
import math
import textwrap

from datetime import datetime
import logging

from rmt_dependency_analysis import RmtDependencyAnalysis
from pygraph.classes.graph import graph
from pygraph.classes.digraph import digraph
from pygraph.algorithms.minmax import shortest_path
from pygraph.algorithms.critical import critical_path

import traceback

# PLOTTING MODULES
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.backends.backend_pdf import PdfPages
except:
    logging.info(traceback.print_exc())
    pass

class RmtConfiguration:
    """
    Module to describe and log an RMT switch configuration
    for a given program
    """
    def __init__(self, program, switch, preprocess,\
                     layout, version):
        self.logger = logging.getLogger(__name__)

        self.program = program
        self.da = RmtDependencyAnalysis(program)
        self.switch = switch
        self.preprocess = preprocess
        self.version = version
        self.stMax = self.switch.numStages
        self.logMax = self.program.MaximumLogicalTables

        self.typeColor = {'action': 'black'}
        for mem in self.switch.memoryTypes:
            self.typeColor[mem] = 'yellow'
            pass

        self.pfMax = {}
        for mem in self.switch.allTypes:
            self.pfMax[mem] = preprocess.layout[mem].shape[1]
            pass
        self.logger.debug("PFMAX: %s" % self.pfMax)
        self.configure(layout)
        pass

    def getWordsPerTable(self):
        """ Get match entries per table per stage. """
        packingUnits = {}
        wordsPerLog = {}

        for log in range(self.logMax):
            wordsPerLog[log] = {}
            for st in range(self.stMax):
                wordsPerLog[log][st] = 0
                pass
            pass
        
        for mem in self.switch.memoryTypes:
            packingUnits[mem] = {}
            for log in range(self.logMax):
                packingUnits[mem][log] = {}
                for st in range(self.stMax):
                    packingUnits[mem][log][st] = {}
                    packingUnitsPresent =\
                    [pf for pf in range(self.pfMax[mem])\
                    if self.layout[mem][log*self.stMax+st, pf] > 0]
                    if len(packingUnitsPresent) == 0:
                        continue
                    elif len(packingUnitsPresent) > 1:
                        roundOkay = \
                            (len([pf for pf in range(self.pfMax[mem])\
                                     if round(self.layout[mem]\
                                                  [log*self.stMax+st, pf]) > 0]) <= 1)
                        level = logging.WARNING
                        if not roundOkay:
                            self.logger.log(level, "For %s, More than 1 packing unit for %s (%s)" %\
                                                 (self.version, self.program.names[log], mem))
                            pass
                        pass
                    pf = packingUnitsPresent[0]
                    numPUnits = self.layout[mem][log*self.stMax+st, pf]
                    if len(self.preprocess.word[mem].shape) == 1:
                        wordsPerPUnit = self.preprocess.word[mem][log]
                        pass
                    else:
                        wordsPerPUnit = self.preprocess.word[mem][log][pf]
                        pass
                    wordsPerLog[log][st] += numPUnits * wordsPerPUnit
                    packingUnits[mem][log][st] =\
                      {'pf':pf, 'wordsPerPUnit':wordsPerPUnit,\
                       'numPUnits': numPUnits}
                    pass
                pass
            pass

        self.packingUnits = packingUnits
        self.wordsPerLog = wordsPerLog

        totalUnassignedWords = 0
        for log in range(self.logMax):
            wordsAssigned = np.floor(sum([wordsPerLog[log][st] for st in range(self.stMax)]))
            wordsNeeded = np.ceil(self.program.logicalTables[log])
            if wordsAssigned < wordsNeeded:
                totalUnassignedWords += wordsNeeded - wordsAssigned
                pass
            pass
        totalWordsNeeded = sum(self.program.logicalTables)
        self.totalUnassignedWords = int(round(totalUnassignedWords))
        # hun_log
        # self.logger.info("Total words unassigned %d out of %d (%.1f p.c.)" %\
        #              (totalUnassignedWords, sum(self.program.logicalTables),\
        #               float(totalUnassignedWords)/totalWordsNeeded))
        pass

    def checkWordsPerTable(self):
        """ Check if enough match entries have been
        assigned for each table """
        totalUnassignedWords = 0
        for log in range(self.logMax):
            wordsAssigned = np.floor(sum([self.wordsPerLog[log][st] for st in range(self.stMax)]))
            wordsNeeded = np.ceil(self.program.logicalTables[log])
            satisfied = 100
            conj = 'and'
            if wordsAssigned < wordsNeeded:
                roundOkay =\
                    (sum([round(self.wordsPerLog[log][st]) for st in range(self.stMax)])\
                         >= wordsNeeded)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                    pass
                totalUnassignedWords += wordsNeeded - wordsAssigned
                satisfied = float(wordsAssigned)/wordsNeeded
                conj = 'but'
                name = self.program.names[log]
                pU = ["%s in St %d" % (self.packingUnits[m][log][s],s)\
                      for m in self.switch.memoryTypes\
                      for s in range(self.stMax) if\
                      len(self.packingUnits[m][log][s])>0]

                self.logger.log(level, "For %s, %s needs %d %s assigned %d (%.1f p.c.):%s" %\
                             (self.version, name, wordsNeeded, conj, wordsAssigned, satisfied, pU))

                pass
            pass
        totalWordsNeeded = sum(self.program.logicalTables)
        # self.logger.info("Total words unassigned %d out of %d (%.1f p.c.)" % (self.totalUnassignedWords, sum(self.program.logicalTables), float(self.totalUnassignedWords)/totalWordsNeeded))
        pass
    
    def configure(self, layout):
        self.layout = layout
        self.getWordsPerTable()
        blocks = {}
        totalBlocks = {}
        for st in range(self.stMax):
            blocks[st] = {}
            totalBlocks[st] = {}
            for log in range(self.logMax):
                blocks[st][log] = {}
                for thing in layout.keys():
                    blocks[st][log][thing] = 0
                    for pf in range(self.pfMax[thing]):
                        numPUnits = layout[thing][log*self.stMax+st, pf]
                        perPfBlocks = self.preprocess.layout[thing][log, pf]
                        if numPUnits > 0:
                            # bl = int(round(numPUnits)) * int(perPfBlocks)
                            bl = numPUnits * perPfBlocks
                            blocks[st][log][thing] += bl
                            pass
                        pass
                    pass
                # totalBlocks[st][log] = sum([round(blocks[st][log][t]) for t in blocks[st][log]])
                totalBlocks[st][log] = sum([blocks[st][log][t] for t in blocks[st][log]])
                pass
            pass
        self.blocks = blocks
        self.totalBlocks = totalBlocks
        pass

    def getNumActiveSrams(self):
        """
        For each table in each stage, 
        - number of RAMs for a match packing units (max if many types)
        - + number of RAMs for an action packing unit
        """

        ramsForPUnits = 0
        for st in range(self.stMax):
            for log in range(self.logMax):
                name = self.program.names[log]
                # match RAM
                ramsPerPUnit = []
                for pf in range(self.pfMax['sram']):
                    numPUnits = \
                        self.layout['sram'][log*self.stMax+st, pf]#)
                    numBlocks = self.preprocess.layout['sram'][log][pf]
                    if  numPUnits > 0:
                        ramsPerPUnit.append(numBlocks)
                        pass
                    pass
                if len(ramsPerPUnit) > 0:
                    if len(ramsPerPUnit) > 1:
                        self.logger.warn("For %s, %d PUnit types, %s match SRAM in %d" %\
                                         (self.version, len(ramsPerPUnit),name, st))
                        pass
                    # ramsForPUnits += int(max(ramsPerPUnit))
                    pass
                # action RAM
                pf = 0
                ramsPerPUnit = self.preprocess.layout['action'][log][pf]
                numPUnits = self.layout['action'][log*self.stMax+st, pf]
                if numPUnits > 0:
                    ramsForPUnits += ramsPerPUnit
                    pass

                pass
            pass
        return ramsForPUnits

    def getNumActiveTcams(self):
        """
        If match data width is less than TCAM width, only 
        a fraction of TCAM is active/ consumes power.
        """

        tcamsForPUnits = 0
        for st in range(self.stMax):
            for log in range(self.logMax):
                for pf in range(self.pfMax['tcam']):
                    # layout['tcam'][log] is not a list, just an int
                    tcamsPerPUnit = self.preprocess.layout['tcam'][log]
                    tcamWidth = tcamsPerPUnit * self.switch.width['tcam']
                    matchWidth = self.program.logicalTableWidths[log]
                    numPUnits =\
                        self.layout['tcam'][log*self.stMax+st, pf]
                        # round(self.layout['tcam'][log*self.stMax+st, pf])
                    tcamsForPUnits += numPUnits * (tcamWidth/matchWidth)
                    pass
                pass
            pass
        return tcamsForPUnits

    def getPowerForRamsAndTcams(self):
        numActiveSrams = self.getNumActiveSrams()
        numActiveTcams = self.getNumActiveTcams()                         
        powerForRamsAndTcams =\
            self.switch.power['wattsPerTcam'] * numActiveTcams +\
            self.switch.power['wattsPerSram'] * numActiveSrams
        self.logger.info("Need %.2fW for %.2f active RAMs and %.2f active TCAMs."%\
                         (powerForRamsAndTcams,numActiveSrams,numActiveTcams))

        return float(powerForRamsAndTcams)

    def getPipelineLatency(self):
        startTimes = self.getStartTimeOfStage()
        # if startTimes[0] < 0:
        #     return -1
        
        pipelineLatency = startTimes[self.stMax-1]
        # self.logger.info("Pipeline latency: ") + str(pipelineLatency)
        return pipelineLatency

    def getStartTimeOfStage(self):
        time = np.zeros(self.stMax)
        # assuming dependencies are satisfied
        endOf = [-1] * self.logMax
        startOf = [-1] * self.logMax

        satisified = True    
        for log in range(self.logMax):
            # why you need to round: self.blocks[.. is the exact decimal
            # value you get from the ILP solution, so it might be something
            # like 1e-70, which CPLEX would take as 0 in its calculations
            # for blockAllMemBin, startStage, pipelinLatency etc.
            # here too, we should round it to 0. Otherwise if a table
            # has 1e-70 blocks in stage st, we'd say st has blocks for
            # the table and starting stage is at least as small.
            # .. fixes the bug where ILP latency didn't match up with this.
            stages = [st for st in range(self.stMax)\
                          if round(sum([self.blocks[st][log][mem]\
                                      for mem in self.switch.memoryTypes])) > 0]
            if len(stages) == 0:
                satisfied = False
                break
            
            endOf[log] = max(stages)
            startOf[log] = min(stages)
            satisfied = not any([endOf[log]==-1, startOf[log]==-1])
            pass

        if not satisfied:
            self.logger.warn("For %s, some table didn't get assigned to any stage." % self.version)
            return [-1] * self.stMax

        succDeps = self.program.logicalSuccessorDependencyList
        warnStr = ""
        for (log1, log2) in succDeps:
            satisfied = startOf[log2] >= endOf[log1]
            if not satisified:
                warnStr += " %s ends in %d, %s starts in %d (s)" %\
                  (self.program.names[log1], endOf[log1],\
                   self.program.names[log2], startOf[log2])
                pass
            pass
        matchDeps = self.program.logicalMatchDependencyList
        for (log1, log2) in matchDeps:
            satisfied = startOf[log2] > endOf[log1]
            if not satisified:
                warnStr += " %s ends in %d, %s starts in %d (m)" %\
                  (self.program.names[log1], endOf[log1],\
                   self.program.names[log2], startOf[log2])
                pass
            pass
        actDeps = self.program.logicalActionDependencyList
        for (log1, log2) in actDeps:
            satisfied = startOf[log2] > endOf[log1]
            if not satisified:
                warnStr += " %s ends in %d, %s starts in %d (a)" %\
                  (self.program.names[log1], endOf[log1],\
                   self.program.names[log2], startOf[log2])
                pass

            pass

        if not satisfied:
            self.logger.warn("For %s: some dependency not satisifed, not checking latency: %s" %\
                                 (self.version, warnStr))
            return [-1] * self.stMax
        
        md = self.switch.matchDelay
        ad = self.switch.actionDelay
        sd = self.switch.successorDelay

        time[0] = 0
        for st in range(1,self.stMax):
            time[st] = max([time[st-1]+sd]+\
                [time[endOf[log1]] + md for (log1, log2) in matchDeps if startOf[log2] == st]+\
                [time[endOf[log1]] + ad for (log1, log2) in actDeps if startOf[log2] == st])
                #            self.logger.info("St " + str(st) + " starts at ") + str(time[st])
            pass
        return time
        pass
        

    def getColorsForTables(self):
        """
        Fills in self.logColors, a map from table index to color info (HEX, tuple)
        """
        logColors = {}

        colors = []
        f = open("simple-colors.txt", "r")
        for line in f:
            words = line.split()
            if "white" in words[0].lower():
                continue
            colors.append((words[0], words[1]))
            pass

        # colors is a list of color hex, name tuples sorted by name
        colors = sorted(colors, key=lambda tup:tup[1])
        random.seed(10)
        random.shuffle(colors)
        numColors = min(len(colors), len(self.program.names))

        index = 1
        self.logColors = {}
        for log in range(len(self.program.names)):
            colorIndex = (index + 1)%len(colors)
            color = colors[index%numColors]
            self.logColors[log] = color
            index += 1
            pass

        for table in self.program.names:
            index = self.program.names.index(table)
            color = self.logColors[index]
            #print "%s: %s" % (table, code)
            pass
        pass

    def showDict(self, d):
        string = ""
        for k in sorted(d.keys()):
            if len(d[k]) > 0:
                string += "%s: %s, " % (k, str(d[k]))
                pass
            pass
        return string

    def showList(sef, l):
        string = ""
        for index in range(len(l)):
            if len(l[index]) > 0:
                string += "%d: %s, " % (index, str(l[index]))
                pass
            pass
        return string
        
    def showPic(self, filename, prefix):
        """
        Output a picture of the configuration to a file called @prefix@filename
        """
        xLeft = 0
        yTop = 0
        xRight = 0
        yBottom = 0

        rect = {}

        self.getColorsForTables()

        # Find last stage that has match/ action blocks in TCAM/ SRAM
        maxStage = -1
        for st in range(self.switch.numStages):
            numBlocks = sum([round(self.blocks[st][log][entryType])
                             for mem in self.switch.memoryTypes
                             for log in range(self.program.MaximumLogicalTables)
                             for entryType in self.switch.typesIn[mem]])
            if (numBlocks > 0):
                maxStage = st
                pass
            pass
        
        if (maxStage == -1):
            self.logger.warn("No match/ action blocks in any stage. Not printing picture.")
            return

        # There is one sub plot for each memory type in each figure
        # Show up to 10 stages per figure

        numFigures = int(math.ceil(maxStage/10.0))
        
        subplots = {}
        memoryTypes = sorted(self.switch.memoryTypes)
        numSubplots = len(memoryTypes) # for memory blocks, legend subplot next to it

        for figNum in range(numFigures):
            fig = plt.figure(figNum+1)
            subplots[figNum] = {}
            for i in range(len(memoryTypes)):
                mem = memoryTypes[i]
                subplots[figNum][mem] =\
                    fig.add_subplot(numSubplots,2,i*len(memoryTypes)+1, xticks=[], yticks=[])
                subplots[figNum]['legend-%s'%(mem)] =\
                    fig.add_subplot(numSubplots,2,i*len(memoryTypes)+2, frame_on=False, xticks=[], yticks=[])
                pass
            pass
        
        
        tablesPerStage = {}

        # Maybe show 20 stages per figure?

        # examples of other entry types (action..) to
        # refer to in legend
        otherPatches = {}
        
        for figNum in range(numFigures):
            startStage = figNum * 10
            endStage = min(startStage + 10 - 1, maxStage)
            numStages = endStage - startStage + 1
            
            self.logger.debug(self.switch.memoryTypes)
            tables = {}
            for mem in self.switch.memoryTypes:
                tables[mem] = {}
                self.logger.debug("In memory: " + mem)
                
                ax = subplots[figNum][mem]
                rect[mem] = [[] for log in range(self.program.MaximumLogicalTables)]
            # Each unit on the Y-axis corresponds to one row of a memory block.
                maxY = self.switch.depth[mem] * self.switch.numBlocks[mem][0]
                minY = 0
                minX = 0
            # Each unit on the X-axis corresponds to one bit of a memory block.
                maxX = self.switch.width[mem] * 10
                #margin = 1000
                ax.set_xlim([minX,maxX])
                ax.set_ylim([minY,maxY])
                for st in range(startStage, endStage+1):
                    # tablesPerStage[mem].append([])
                    xLeft = (st-startStage) * self.switch.width[mem]
                    ax.add_line(matplotlib.lines.Line2D([xLeft,xLeft],[minY,maxY], lw=1, color='k'))
                # Block number where new table starts (all blocks in stage in one column in figure)
                    startBlock = 0
                    for log in range(self.program.MaximumLogicalTables):
                        totalMemBlocks = 0
                        for entryType in self.switch.typesIn[mem]:
                            numEntryTypeBlocks = self.blocks[st][log][entryType]
                            totalMemBlocks += numEntryTypeBlocks
                            
                            color = self.typeColor[entryType]
                            if entryType in self.switch.memoryTypes:
                                color = self.logColors[log][1]
                                colorName = self.logColors[log][0]
                                pass

                        # add a patch in stage for log blocks of entryType in mem
                            if numEntryTypeBlocks > 0:
                                name = self.program.names[log]
                                if name not in tables[mem]:
                                    tables[mem][name] = {'start': st, 'color':colorName, 'end': st}
                                    pass
                                else:
                                    tables[mem][name]['end'] = st
                                    pass

                                if entryType not in tables[mem][name]:
                                    tables[mem][name][entryType] = 0
                                    pass

                                
                                tables[mem][name][entryType] += numEntryTypeBlocks

                                yTop = maxY - startBlock * self.switch.depth[mem] # e.g., Row 0 at y=1000
                                height = numEntryTypeBlocks * self.switch.depth[mem]
                                yBottom = yTop - height
                                width = self.switch.width[mem]
                                patch = matplotlib.patches.Rectangle((xLeft, yBottom),\
                                                                     width,height,\
                                                                     color=color)

                                if 'patch' not in tables[mem][name]:
                                    tables[mem][name]['patch'] = patch                                        
                                    pass
                                if entryType == mem:
                                    tables[mem][name]['patch'] = patch
                                    pass
                                elif entryType not in otherPatches:
                                    otherPatches[entryType] = patch
                                    pass
                                ax.add_patch(patch)
                                pass
                        
                            startBlock += numEntryTypeBlocks
                            pass
                        pass # ends for log in 
                    
                # add a line between st and st-1, and annotate stage st (starting at 1)
                    startOfStage = xLeft 
                    ax.annotate(str(st+1), (startOfStage+5, minY) , color='r')
                    ax.add_line(matplotlib.lines.Line2D([startOfStage, startOfStage],[minY,maxY], lw=5, color='k'))
                    pass                

                if (endStage == maxStage):
                    endOfMaxStage = (maxStage+1-startStage) * self.switch.width[mem]
                    ax.add_line(matplotlib.lines.Line2D([endOfMaxStage, endOfMaxStage],[minY,maxY], lw=5, color='k'))
                    pass

                self.logger.debug("Done with " + mem)
                pass

            for mem in self.switch.memoryTypes:
                ax = subplots[figNum]['legend-%s'%mem]
                ax.set_xlim([0,400])
                ax.set_ylim([0, 300])

                patches = []
                labels = []

                for t in tables[mem]:
                    if mem not in tables[mem][t]:
                        tables[mem][t][mem] = 0
                        pass
                    pass

                listTables = sorted(tables[mem].keys(), key= lambda name: tables[mem][name][mem], reverse=True)
                numTables = 0
                for t in listTables:
                    if (tables[mem][t][mem]==0):
                        continue
                    entryTypes = sorted([s for s in self.switch.typesIn[mem] if s in tables[mem][t].keys()])
                    blocksStr = ", ".join(\
                        ["%s %s" % (tables[mem][t][entryType], entryType)\
                             for entryType in entryTypes if tables[mem][t][entryType] > 0])
                    stageStr = "%2d" % (tables[mem][t]['start']+1)
                    if tables[mem][t]['start'] < tables[mem][t]['end']:
                        stageStr += "-%2d" % (tables[mem][t]['end']+1)
                        pass
                    if (len(labels) < 12):
                        patches.append(tables[mem][t]['patch'])
                        labels.append("%20s (%s) in %s" % (t, blocksStr, stageStr))
                        pass
                    numTables += 1
                    pass
                if mem == 'sram':
                    for other in otherPatches:
                        patches.append(otherPatches[other])
                        labels.append("%12s blocks" % other)
                        pass
                    pass
                mainStr = "%s Blocks in stages %2d-%2d" % (mem.upper(), startStage+1, endStage+1)
                if (numTables > len(labels)):
                    ax.text(0, 0, " (showing legend for %d of %d tables)" % (len(labels), numTables), fontsize=6)
                    pass
                ax.set_title(mainStr)
                ax.legend(patches, labels, prop={'size':6})
                pass
                
            
            self.logger.debug("Done with stages through " + str(endStage))
            pass
    
#         i = 2
#         for mem in self.switch.memoryTypes:
#             figText = plt.figure(i)
#             i += 1
#             ax = figText.add_subplot(111)
#             tablesPerStagePara = textwrap.fill("%s: " % mem.upper() +\
#                                                    self.showList(tablesPerStage[mem]))
#             ax.text(0, 0.5, tablesPerStagePara, fontsize=10)
#             pass

#         figText = plt.figure(i)
#         ax = figText.add_subplot(111)
#         colorGroupsPara = textwrap.fill("LEGEND: " + self.showDict(colors['colorGroups']))

#         ax.text(0, 0.5, colorGroupsPara, fontsize=10)
#         numFigs = i
        t = datetime.now()
        picFile = prefix + filename + ".pdf"
        pp = PdfPages(picFile)
        for i in range(1,numFigures+1):
            pp.savefig(i)
            pass
        pp.close()
        plt.close('all')
        pass

    def getEarliestStageFromAssign(self, assignInfo):
        """ Returns a mapping from tables
        to information about the first stage they could have started
        in- a table must start after all the tables it depends on
        have been completely assigned. The informations is a list of
         lists [@st, @dep, @prev, @prevEnd] which should be read as        
        Table xx can't start before stage @st because of @dependency
        on table @prev which ends in stage @prevEnd, one for each
        @prev that the table depends on.
        """
        gr = self.da.getDigraph()
        earliestStageFromAssign = {}
        for table in self.program.names:
            previousTables = gr.neighbors(table)
            previousTablesAssigned = True
            for prev in previousTables:
                if prev == 'start':
                    continue
                if prev not in assignInfo\
                        or 'end' not in assignInfo[prev]\
                        or assignInfo[prev]['end'] == -1:
                    self.logger.warn("For %s, %s must be assigned before assigning %s"\
                                     % (self.version, prev, table))
                    previousTablesAssigned = False
                    pass
                pass
            earliestStages = []
            if previousTablesAssigned:
                for prev in previousTables:
                    if prev == 'start':
                        continue
                    prevEnd = assignInfo[prev]['end']
                    edge = (table,prev)
                    edgeWeight = int(abs(gr.edge_weight(edge)))
                    tableStart = prevEnd + edgeWeight
                    attr = gr.edge_attributes(edge)
                    props = {"type":""}
                    for key, val in attr:
                        props[key] = val
                        pass
                    edgeType = props["type"]
                    earliestStages.append((tableStart, edgeType, prev, prevEnd))
                    pass
            earliestStageFromAssign[table] =\
                sorted(earliestStages, key = lambda tup: tup[0], reverse=True)
            pass
        return earliestStageFromAssign

    def display(self, paths = []):
        """ Display configuration, in many different ways- fraction of TCAMs/ SRAMs used, power, pipeline latency
        start time of stages, tables in each stage, memories used by tables in each stage, dependencies
        that force tables to start in a particular stage (useful for debugging program manually)
        """
        self.checkWordsPerTable()
        
#         self.logger.info("Fraction of TCAMs/ SRAMs used")
#         self.displayFractionUsed()
        
        self.logger.info("\n(%s) Power for RAMs and TCAMs " % self.version + str(self.getPowerForRamsAndTcams()))
        self.logger.info("\n(%s) Pipeline Latency " % self.version + str(self.getPipelineLatency()))

#         self.logger.info("\n(%s)Start Time of Stages " % self.version) 
#         startTime = self.getStartTimeOfStage()
#         for st in range(self.stMax):
#             self.logger.info("St " + str(st) + ": " + str(startTime[st]))
#             pass
        
        
        summaryInfo = ""
        layoutInfo = ""

        
        layoutPerSt = {}
        summaryPerSt = {}
        stageInfo = {}
        perLogProgramInfo = self.da.getPerLogProgramInfo()
        for st in range(self.stMax):
            layoutPerSt[st] = {}
            summaryPerSt[st] = []
            stageInfo[st] = ""
            for log in range(self.logMax):
                if self.totalBlocks[st][log] > 0:
                    name = self.program.names[log]
                    summaryPerSt[st].append("%s (%d)" % (name, perLogProgramInfo[name]['earliestStage']))
                    layout = ", ".join(["%d %s" % (self.blocks[st][log][t],t[0])\
                                            for t in self.blocks[st][log]\
                                            if self.blocks[st][log][t] > 0])
                    layoutPerSt[st][log] = "%s (%s)  " % (name, layout)
                    pass
                pass
            
            totalMatchBlocks = {}
            for mem in self.switch.memoryTypes:
                totalMatchBlocks[mem] = sum([self.blocks[st][log][thing]\
                                                 for log in range(self.logMax) for\
                                                 thing in self.switch.typesIn[mem]])
                pass

            text = ", ".join(["%d %ss" % (totalMatchBlocks[mem], mem.upper()) for mem in self.switch.memoryTypes])
            stageInfo[st] = "Stage %d (%s): " % (st, text)
                
            pass
        
#         self.logger.info("\n(%s) Tables allocated per stage (earliest possible stage in brackets)\n" % self.version + summaryInfo)
#         for st in sorted(summaryPerSt.keys()):
#             if len(summaryPerSt[st]) > 0:
#                 self.logger.info("%s: %s" % (stageInfo[st], ",".join(summaryPerSt[st])))
#                 pass
#             pass
        
        self.logger.info("\n(%s) Blocks allocated per stage\n" % self.version + layoutInfo)
        for st in sorted(layoutPerSt.keys()):
            if len(layoutPerSt[st]) > 0:
                sortedLogs = sorted(layoutPerSt[st].keys(),\
                                        key = lambda log: self.totalBlocks[st][log], reverse = True)
                layouts = ", ".join([layoutPerSt[st][log] for log in sortedLogs])
                self.logger.info("%s: %s" % (stageInfo[st], layouts))
                pass
            pass

        assignInfo =  self.getPerLogAssignInfo()

        self.logger.info("\n(%s) Table xx can't start before stage @st because of @dependency on table @prev which ends in stage @prevEndSt [(st, dependency, prev, prevEndSt),..]" % self.version)
        notBefore = self.getEarliestStageFromAssign(assignInfo)
        for table in self.program.names:
            previousTables = notBefore[table]
            self.logger.info("%s  : %s" % (table, previousTables))
            pass

        pass

    def getPerLogAssignInfo(self):
        """
         Return mapping from table to assignment info
          'start': start stage (or -1 if not valid)
          'end': end stage (or -1 if not valid)
        """
        blocks = self.blocks
        perLogAssignInfo = {}
        for log in range(self.logMax):
            inStages = [st for st in range(self.stMax)\
                                  if any([blocks[st][log][mem] > 0\
                                              for mem in blocks[st][log].keys()])]
            if len(inStages) > 0:
                startStage = min(inStages)
                endStage = max(inStages)
                pass
            else:
                startStage = -1
                endStage = -1
                pass

            name = self.program.names[log]
            perLogAssignInfo[name] = {'start': startStage, 'end': endStage}
            pass
        return perLogAssignInfo


    def displayFractionUsed(self):
        stagesUsed = [st for st in range(self.stMax) if\
                                 sum([self.blocks[st][log][mem]
                                      for mem in self.switch.memoryTypes\
                                      for log in range(self.logMax)]) >= 1]
        numStagesUsed = 0
        if len(stagesUsed) > 0:
            numStagesUsed = max(stagesUsed)
                                        
        self.logger.info("(%s) Number of stages used -%d" % (self.version, numStagesUsed+1))

        self.logger.info("Total in all # stages -")
        self.logger.info(self.blocks[st][log].keys())

        for mem in self.switch.memoryTypes:
            usedBlocks = sum([self.blocks[st][log][thing]\
                                  for log in range(self.logMax)\
                                  for st in range(self.stMax)\
                                  for thing in self.switch.typesIn[mem]])

            totalBlocks = sum(self.switch.numBlocks[mem])
            self.logger.info("(%s) %d Total %ss used (%.1f pc)" %\
                             (self.version, usedBlocks, mem.upper(),\
                                  round((100.0 * usedBlocks)/totalBlocks)))

            pass

        for st in range(numStagesUsed):
            self.logger.info("Ingress Stage%d -" % st)
            for mem in self.switch.memoryTypes:
                usedBlocks = sum([self.blocks[st][log][thing]\
                                      for log in range(self.logMax)\
                                      for thing in self.switch.typesIn[mem]])

                totalBlocks = self.switch.numBlocks[mem][st]
                numTables = sum([1 for log in range(self.logMax)\
                                          if self.blocks[st][log][mem] > 0])

                if (usedBlocks > totalBlocks):
                    roundOkay = (sum([round(self.blocks[st][log][thing])\
                                         for log in range(self.logMax)\
                                         for thing in self.switch.typesIn[mem]]) <= totalBlocks)
                    level = logging.WARNING
                    if not roundOkay:
                        level = logging.ERROR
                        pass
                    self.logger.log(level, "For %s: More blocks used (%d) than available (%d) in St %d" %\
                                 (self.version, usedBlocks, totalBlocks, st))
                    pass
                self.logger.info("(%s) %d Total %ss used (%.1f pc), %d Tables" %\
                                 (self.version, usedBlocks, mem.upper(),\
                                      round((100.0 * usedBlocks)/totalBlocks),\
                                                numTables))
                pass
            pass
        pass
    
    def displayInitialConditions(self):
        self.logger.info("(%s) Initial conditions" % self.version)

        self.logger.info("number of entries in logical table")
        self.showIntList(self.program.logicalTables, self.program.names, extra_arrs=[self.program.logicalTableWidths, self.preprocess.use['tcam'].T], arr_names=["#entries", "width", "TCAM use"])
        self.logger.info("action data widths for each logical table")
        for log in range(self.logMax):
            self.logger.info(self.program.names[log] + ": " \
                + str(self.program.logicalTableActionWidths[log]))
            pass
        pass
        
    def showIntList(self, arr, names=[], extra_arrs=[], arr_names=[]):
        arrs = [arr]
        string = ""
        if len(extra_arrs) > 0:
            for extra_arr in extra_arrs:
                arrs.append(extra_arr)

        string += ("".ljust(10)+ "\t")
        for i in range(len(arr_names)):
            string += (arr_names[i] + "\t")
        string += ("\n")

        rows = len(arr)
        for i in range(rows):
            if (len(names) > 0):
                string += (names[i].ljust(10) + "\t")
        for arr in arrs:
            if int(round(arr[i]))/1000 >= 1:
                string += (str(int(round(arr[i]))/1000) + "k\t")
            else:
                string += (str(int(round(arr[i]))) + "\t")
            string += "\n"
        self.logger.info("(%s)\n" % self.version + string)
        pass

    def showInt(self, num):
        if int(round(num))/1000 >= 1:
            return(str(int(round(num))/1000) + "k")
        else:
            return(str(int(round(num))))

    def showIntArray(self, arr, names=[]):
        string = ""
        rows, cols = arr.shape
        for i in range(rows):
            if (len(names) > 0):
                string += (names[i].ljust(10) + "\t")
                pass
            for l in range(cols):
                if int(round(arr[i,l]))/1000 >= 1:
                    string += (str(int(round(arr[i,l]))/1000) + "k\t")
                elif arr[i,l] > 0.01:
                    string += (str(int(round(arr[i,l]))) + "\t")
                pass
            string += "\n"
            pass
        self.logger.info("(%s) " % self.version + string)
        pass
    
    def makeArrayToList(self, arr):
        """
        Makes an encapsulated array [[2], [5], [4]] into a list [2, 5, 4].
        """
        ret = np.array([])
        rows, cols = arr.shape
        for i in range(rows):
            for l in range(cols):
                ret = np.append(ret, arr[i,l])
                pass
            pass
        pass
        return ret.tolist()
