import { Controller, Get, Param } from '@nestjs/common';
import { CatalogService } from './catalog.service';

@Controller('products')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  /** GET /api/products */
  @Get()
  findAll() {
    return this.catalogService.findAll();
  }

  /** GET /api/products/:id */
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.catalogService.findOne(id);
  }
}
