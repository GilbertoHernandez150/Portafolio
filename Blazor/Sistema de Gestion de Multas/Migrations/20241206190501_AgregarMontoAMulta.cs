using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace finalweb.Migrations
{
    /// <inheritdoc />
    public partial class AgregarMontoAMulta : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "Monto",
                table: "ConceptosMultas",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Monto",
                table: "ConceptosMultas");
        }
    }
}
