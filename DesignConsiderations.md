# Introduction #

In this page we reference the Wiki pages describing our design key points and trade-offs

# Details #

We discuss the following points

  * [How does the interface with external memory look like](ExternalMemoryInterface.md)
  * [How Memory stage synchronize with Execute, Write-Back and External Memory](MemoryStageCycleTime.md)
  * [Decode Register File must not progress until the 3rd Write Back received](RFWriteThenRead.md)
  * [Describing how RAW Hazards are resolved](RAWHazards.md)
  * [How loading from memory into register will avoid hazards](DataHazard.md)
  * [How Memory to Register Hazard is handled](MemToRegHazard.md)