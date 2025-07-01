#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Define memory file path using environment variable with fallback
const defaultMemoryPath = path.join(path.dirname(fileURLToPath(import.meta.url)), 'memory.json');
// If MEMORY_FILE_PATH is just a filename, put it in the same directory as the script
const MEMORY_FILE_PATH = process.env.MEMORY_FILE_PATH ? path.isAbsolute(process.env.MEMORY_FILE_PATH) ? process.env.MEMORY_FILE_PATH : path.join(path.dirname(fileURLToPath(import.meta.url)), process.env.MEMORY_FILE_PATH) : defaultMemoryPath;

// We are storing our memory using entities, relations, and observations in a graph structure
interface Entity {
  name: string;
  entityType: string;
  observations: string[];
}

interface Relation {
  from: string;
  to: string;
  relationType: string;
}

interface KnowledgeGraph {
  entities: Entity[];
  relations: Relation[];
}

// The KnowledgeGraphManager class contains all operations to interact with the knowledge graph
class KnowledgeGraphManager {
  private async loadGraph(): Promise<KnowledgeGraph> {
    try {
      const data = await fs.readFile(MEMORY_FILE_PATH, "utf-8");
      const lines = data.split("\n").filter(line => line.trim() !== "");
      return lines.reduce((graph: KnowledgeGraph, line) => {
        const item = JSON.parse(line);
        if (item.type === "entity") graph.entities.push(item as Entity);
        if (item.type === "relation") graph.relations.push(item as Relation);
        return graph;
      }, { entities: [], relations: [] });
    } catch (error) {
      if (error instanceof Error && 'code' in error && (error as any).code === "ENOENT") {
        return { entities: [], relations: [] };
      }
      throw error;
    }
  }

  private async saveGraph(graph: KnowledgeGraph): Promise<void> {
    const lines = [
      ...graph.entities.map(e => JSON.stringify({ type: "entity", ...e })),
      ...graph.relations.map(r => JSON.stringify({ type: "relation", ...r })),
    ];
    await fs.writeFile(MEMORY_FILE_PATH, lines.join("\n"));
  }

  async createEntities(entities: Entity[]): Promise<Entity[]> {
    const graph = await this.loadGraph();
    const newEntities = entities.filter(e => !graph.entities.some(existingEntity => existingEntity.name === e.name));
    graph.entities.push(...newEntities);
    await this.saveGraph(graph);
    return newEntities;
  }

  async createRelations(relations: Relation[]): Promise<Relation[]> {
    const graph = await this.loadGraph();
    const newRelations = relations.filter(r => !graph.relations.some(existingRelation => existingRelation.from === r.from && existingRelation.to === r.to && existingRelation.relationType === r.relationType ));
    graph.relations.push(...newRelations);
    await this.saveGraph(graph);
    return newRelations;
  }

  async addObservations(observations: { entityName: string; contents: string[] }[]): Promise<{ entityName: string; addedObservations: string[] }[]> {
    const graph = await this.loadGraph();
    const results = observations.map(o => {
      const entity = graph.entities.find(e => e.name === o.entityName);
      if (!entity) {
        throw new Error(`Entity with name ${o.entityName} not found`);
      }
      const newObservations = o.contents.filter(content => !entity.observations.includes(content));
      entity.observations.push(...newObservations);
      return { entityName: o.entityName, addedObservations: newObservations };
    });
    await this.saveGraph(graph);
    return results;
  }

  async deleteEntities(entityNames: string[]): Promise<void> {
    const graph = await this.loadGraph();
    graph.entities = graph.entities.filter(e => !entityNames.includes(e.name));
    graph.relations = graph.relations.filter(r => !entityNames.includes(r.from) && !entityNames.includes(r.to));
    await this.saveGraph(graph);
  }

  async deleteObservations(deletions: { entityName: string; observations: string[] }[]): Promise<void> {
    const graph = await this.loadGraph();
    deletions.forEach(d => {
      const entity = graph.entities.find(e => e.name === d.entityName);
      if (entity) {
        entity.observations = entity.observations.filter(o => !d.observations.includes(o));
      }
    });
    await this.saveGraph(graph);
  }

  async deleteRelations(relations: Relation[]): Promise<void> {
    const graph = await this.loadGraph();
    graph.relations = graph.relations.filter(r => !relations.some(delRelation => r.from === delRelation.from && r.to === delRelation.to && r.relationType === delRelation.relationType ));
    await this.saveGraph(graph);
  }

  async readGraph(): Promise<KnowledgeGraph> {
    return this.loadGraph();
  }

  // Very basic search function
  async searchNodes(query: string): Promise<Entity[]> {
    const graph = await this.loadGraph();
    // Filter entities
    const filteredEntities = graph.entities.filter(e =>
      e.name.toLowerCase().includes(query.toLowerCase()) ||
      e.entityType.toLowerCase().includes(query.toLowerCase()) ||
      e.observations.some(o => o.toLowerCase().includes(query.toLowerCase()))
    );
    // Create a Set of filtered entity names for quick lookup
    const filteredEntityNames = new Set(filteredEntities.map(e => e.name));
    // Filter relations to include only those between filtered entities
    const relationsBetweenFilteredEntities = graph.relations.filter(r =>
      filteredEntityNames.has(r.from) && filteredEntityNames.has(r.to)
    );
    // Attach relations to entities (optional, depending on desired output)
    return filteredEntities.map(entity => ({
      ...entity,
      relations: relationsBetweenFilteredEntities.filter(r => r.from === entity.name || r.to === entity.name)
    }));
  }

  async openNodes(names: string[]): Promise<Entity[]> {
    const graph = await this.loadGraph();
    const requestedEntities = graph.entities.filter(e => names.includes(e.name));
    const requestedEntityNames = new Set(requestedEntities.map(e => e.name));
    const relationsBetweenRequestedEntities = graph.relations.filter(r =>
      requestedEntityNames.has(r.from) && requestedEntityNames.has(r.to)
    );
    return requestedEntities.map(entity => ({
      ...entity,
      relations: relationsBetweenRequestedEntities.filter(r => r.from === entity.name || r.to === entity.name)
    }));
  }
}

class MemoryServer {
  private server: Server;
  private kgManager: KnowledgeGraphManager;

  constructor() {
    this.server = new Server(
      {
        name: "memory",
        version: "0.1.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    this.kgManager = new KnowledgeGraphManager();
    this.setupToolHandlers();
  }

  private setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "create_entities",
          description: "Create multiple new entities in the knowledge graph",
          inputSchema: {
            type: "object",
            properties: {
              entities: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    name: { type: "string" },
                    entityType: { type: "string" },
                    observations: { type: "array", items: { type: "string" } },
                  },
                  required: ["name", "entityType", "observations"],
                },
              },
            },
            required: ["entities"],
          },
        },
        {
          name: "create_relations",
          description: "Create multiple new relations between entities",
          inputSchema: {
            type: "object",
            properties: {
              relations: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    from: { type: "string" },
                    to: { type: "string" },
                    relationType: { type: "string" },
                  },
                  required: ["from", "to", "relationType"],
                },
              },
            },
            required: ["relations"],
          },
        },
        {
          name: "add_observations",
          description: "Add new observations to existing entities",
          inputSchema: {
            type: "object",
            properties: {
              observations: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    entityName: { type: "string" },
                    contents: { type: "array", items: { type: "string" } },
                  },
                  required: ["entityName", "contents"],
                },
              },
            },
            required: ["observations"],
          },
        },
        {
          name: "delete_entities",
          description: "Remove entities and their relations",
          inputSchema: {
            type: "object",
            properties: {
              entityNames: { type: "array", items: { type: "string" } },
            },
            required: ["entityNames"],
          },
        },
        {
          name: "delete_observations",
          description: "Remove specific observations from entities",
          inputSchema: {
            type: "object",
            properties: {
              deletions: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    entityName: { type: "string" },
                    observations: { type: "array", items: { type: "string" } },
                  },
                  required: ["entityName", "observations"],
                },
              },
            },
            required: ["deletions"],
          },
        },
        {
          name: "delete_relations",
          description: "Remove specific relations from the graph",
          inputSchema: {
            type: "object",
            properties: {
              relations: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    from: { type: "string" },
                    to: { type: "string" },
                    relationType: { type: "string" },
                  },
                  required: ["from", "to", "relationType"],
                },
              },
            },
            required: ["relations"],
          },
        },
        {
          name: "read_graph",
          description: "Read the entire knowledge graph",
          inputSchema: { type: "object", properties: {} },
        },
        {
          name: "search_nodes",
          description: "Search for nodes based on query",
          inputSchema: {
            type: "object",
            properties: {
              query: { type: "string" },
            },
            required: ["query"],
          },
        },
        {
          name: "open_nodes",
          description: "Retrieve specific nodes by name",
          inputSchema: {
            type: "object",
            properties: {
              names: { type: "array", items: { type: "string" } },
            },
            required: ["names"],
          },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      switch (request.params.name) {
        case "create_entities":
          const createEntitiesArgs = request.params.arguments as { entities: Entity[] };
          if (!createEntitiesArgs || !createEntitiesArgs.entities) {
            throw new Error("Invalid arguments for create_entities");
          }
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(await this.kgManager.createEntities(
                  createEntitiesArgs.entities
                ), null, 2),
              },
            ],
          };
        case "create_relations":
          const createRelationsArgs = request.params.arguments as { relations: Relation[] };
          if (!createRelationsArgs || !createRelationsArgs.relations) {
            throw new Error("Invalid arguments for create_relations");
          }
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(await this.kgManager.createRelations(
                  createRelationsArgs.relations
                ), null, 2),
              },
            ],
          };
        case "add_observations":
          const addObservationsArgs = request.params.arguments as { observations: { entityName: string; contents: string[] }[] };
          if (!addObservationsArgs || !addObservationsArgs.observations) {
            throw new Error("Invalid arguments for add_observations");
          }
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(await this.kgManager.addObservations(
                  addObservationsArgs.observations
                ), null, 2),
              },
            ],
          };
        case "delete_entities":
          const deleteEntitiesArgs = request.params.arguments as { entityNames: string[] };
          if (!deleteEntitiesArgs || !deleteEntitiesArgs.entityNames) {
            throw new Error("Invalid arguments for delete_entities");
          }
          await this.kgManager.deleteEntities(deleteEntitiesArgs.entityNames);
          return { content: [] };
        case "delete_observations":
          const deleteObservationsArgs = request.params.arguments as { deletions: { entityName: string; observations: string[] }[] };
          if (!deleteObservationsArgs || !deleteObservationsArgs.deletions) {
            throw new Error("Invalid arguments for delete_observations");
          }
          await this.kgManager.deleteObservations(
            deleteObservationsArgs.deletions
          );
          return { content: [] };
        case "delete_relations":
          const deleteRelationsArgs = request.params.arguments as { relations: Relation[] };
          if (!deleteRelationsArgs || !deleteRelationsArgs.relations) {
            throw new Error("Invalid arguments for delete_relations");
          }
          await this.kgManager.deleteRelations(deleteRelationsArgs.relations);
          return { content: [] };
        case "read_graph":
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(await this.kgManager.readGraph(), null, 2),
              },
            ],
          };
        case "search_nodes":
          const searchNodesArgs = request.params.arguments as { query: string };
          if (!searchNodesArgs || !searchNodesArgs.query) {
            throw new Error("Invalid arguments for search_nodes");
          }
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(await this.kgManager.searchNodes(
                  searchNodesArgs.query
                ), null, 2),
              },
            ],
          };
        case "open_nodes":
          const openNodesArgs = request.params.arguments as { names: string[] };
          if (!openNodesArgs || !openNodesArgs.names) {
            throw new Error("Invalid arguments for open_nodes");
          }
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(await this.kgManager.openNodes(
                  openNodesArgs.names
                ), null, 2),
              },
            ],
          };
        default:
          throw new Error(`Unknown tool: ${request.params.name}`);
      }
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Memory MCP server running on stdio");
  }
}

const server = new MemoryServer();
server.run().catch(console.error);
