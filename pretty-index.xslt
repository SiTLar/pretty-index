<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="utf-8" indent="yes" />
  
  <!-- Safely handle parameters -->
  <xsl:param name="sort"/>
  <xsl:param name="order"/>
  <xsl:param name="debug"/>
  
  <!-- Set safe defaults -->
  <xsl:variable name="safe-sort">
    <xsl:choose>
      <xsl:when test="$sort = 'size' or $sort = 'mtime'">
        <xsl:value-of select="$sort"/>
      </xsl:when>
      <xsl:otherwise>name</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="safe-order">
    <xsl:choose>
      <xsl:when test="$order = 'desc' or $order = 'descending' or $order = '1'">
        <xsl:text>descending</xsl:text>
      </xsl:when>
      <xsl:otherwise>ascending</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="safe-debug">
    <xsl:choose>
      <xsl:when test="$debug = '1' or $debug = 'true'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- Main template -->
  <xsl:template match="/*">
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Index of <xsl:value-of select="@path"/></title>
        <style>
          /* Modern CSS styling */
          :root {
            --bg-color: #f8f9fa;
            --text-color: #212529;
            --border-color: #dee2e6;
            --header-bg: #e9ecef;
            --row-hover: #f1f3f5;
            --link-color: #0d6efd;
            --icon-folder: #6f42c1;
            --icon-file: #6c757d;
          }
          
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--bg-color);
            margin: 2rem;
          }
          
          .container {
            max-width: 1200px;
            margin: 0 auto;
          }
          
          h1 {
            font-size: 1.8rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--border-color);
          }
          
          table {
            width: 100%;
            border-collapse: collapse;
            box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
            background: white;
            border-radius: 0.25rem;
            overflow: hidden;
          }
          
          th {
            background-color: var(--header-bg);
            text-align: left;
            padding: 0.75rem 1rem;
            cursor: pointer;
            user-select: none;
          }
          
          th:hover {
            background-color: #dde0e3;
          }
          
          td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border-color);
          }
          
          tr:last-child td {
            border-bottom: none;
          }
          
          tr:hover td {
            background-color: var(--row-hover);
          }
          
          .icon {
            display: inline-block;
            width: 1.25rem;
            text-align: center;
            margin-right: 0.5rem;
          }
          
          .folder {
            color: var(--icon-folder);
          }
          
          .file {
            color: var(--icon-file);
          }
          
          a {
            color: var(--text-color);
            text-decoration: none;
            display: block;
          }
          
          a:hover {
            color: var(--link-color);
          }
          
          .size {
            text-align: right;
            font-variant-numeric: tabular-nums;
          }
          
          .date {
            white-space: nowrap;
          }
          
          .debug {
            background-color: #fff3cd;
            padding: 1rem;
            margin: 1rem 0;
            border-radius: 0.25rem;
            font-family: monospace;
          }
          
          .sort-indicator {
            margin-left: 5px;
          }
          
          /* Responsive design */
          @media (max-width: 768px) {
            .hide-mobile {
              display: none;
            }
            
            th, td {
              padding: 0.5rem;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Index of <xsl:value-of select="@path"/></h1>
          
          <!-- Debug information -->
          <xsl:if test="$safe-debug = '1'">
            <div class="debug">
              <strong>Debug Information:</strong><br/>
              Root Element: <xsl:value-of select="name()"/><br/>
              Safe Sort: <xsl:value-of select="$safe-sort"/><br/>
              Safe Order: <xsl:value-of select="$safe-order"/><br/>
              Directory Count: <xsl:value-of select="count(directory)"/><br/>
              File Count: <xsl:value-of select="count(file)"/><br/>
              Total Entries: <xsl:value-of select="count(directory) + count(file)"/>
            </div>
          </xsl:if>
          
          <!-- Directory listing -->
          <table id="directory-listing">
            <thead>
              <tr>
                <th data-sort="name" onclick="sortTable('name')">
                  Name <span id="name-indicator" class="sort-indicator"></span>
                </th>
                <th class="size" data-sort="size" onclick="sortTable('size')">
                  Size <span id="size-indicator" class="sort-indicator"></span>
                </th>
                <th class="date hide-mobile" data-sort="mtime" onclick="sortTable('mtime')">
                  Modified <span id="mtime-indicator" class="sort-indicator"></span>
                </th>
              </tr>
            </thead>
            <tbody id="listing-body">
              <!-- Parent directory link -->
              <tr>
                <td>
                  <div class="icon folder">📁</div>
                  <a href="../">Parent Directory</a>
                </td>
                <td class="size">-</td>
                <td class="date hide-mobile">-</td>
              </tr>
              
              <!-- Directories -->
              <xsl:for-each select="directory">
                <tr class="directory-entry" 
                    data-name="{.}" 
                    data-mtime="{@mtime}" 
                    data-type="dir">
                  <td>
                    <div class="icon folder">📁</div>
                    <a href="{.}/">
                      <xsl:value-of select="."/>/
                    </a>
                  </td>
                  <td class="size">-</td>
                  <td class="date hide-mobile">
                    <xsl:value-of select="substring(@mtime, 1, 16)"/>
                  </td>
                </tr>
              </xsl:for-each>
              
              <!-- Files -->
              <xsl:for-each select="file">
                <tr class="file-entry" 
                    data-name="{.}" 
                    data-size="{@size}" 
                    data-mtime="{@mtime}" 
                    data-type="file">
                  <td>
                    <div class="icon file">📄</div>
                    <a href="{.}">
                      <xsl:value-of select="."/>
                    </a>
                  </td>
                  <td class="size">
                    <xsl:value-of select="@size"/>
                  </td>
                  <td class="date hide-mobile">
                    <xsl:value-of select="substring(@mtime, 1, 16)"/>
                  </td>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>
        
        <!-- JavaScript for client-side sorting -->
        <script>
        <![CDATA[
          // Current sort state
          let currentSort = 'name';
          let currentOrder = 'ascending';
          
          // DOM elements
          const tableBody = document.getElementById('listing-body');
          const nameIndicator = document.getElementById('name-indicator');
          const sizeIndicator = document.getElementById('size-indicator');
          const mtimeIndicator = document.getElementById('mtime-indicator');
          
          // Initialize from URL parameters
          function initFromUrl() {
            const urlParams = new URLSearchParams(window.location.search);
            const sortParam = urlParams.get('sort');
            const orderParam = urlParams.get('order');
            
            if (sortParam) currentSort = sortParam;
            if (orderParam) currentOrder = orderParam;
            
            // Update sort indicators
            updateSortIndicators();
          }
          
          // Update sort direction indicators
          function updateSortIndicators() {
            // Reset all indicators
            nameIndicator.textContent = '';
            sizeIndicator.textContent = '';
            mtimeIndicator.textContent = '';
            
            // Set active indicator
            if (currentSort === 'name') {
              nameIndicator.textContent = currentOrder === 'ascending' ? '▲' : '▼';
            } else if (currentSort === 'size') {
              sizeIndicator.textContent = currentOrder === 'ascending' ? '▲' : '▼';
            } else if (currentSort === 'mtime') {
              mtimeIndicator.textContent = currentOrder === 'ascending' ? '▲' : '▼';
            }
          }
          
          // Sort table function
          function sortTable(column) {
            // Toggle order if same column
            if (currentSort === column) {
              currentOrder = currentOrder === 'ascending' ? 'descending' : 'ascending';
            } else {
              currentSort = column;
              currentOrder = 'ascending';
            }
            
            // Update URL without reloading
            const url = new URL(window.location);
            url.searchParams.set('sort', currentSort);
            url.searchParams.set('order', currentOrder);
            window.history.replaceState(null, '', url);
            
            // Perform the sort
            performSort();
          }
          
          // Perform the actual sorting
          function performSort() {
            // Get all entries except parent directory
            const entries = Array.from(tableBody.querySelectorAll('tr:not(:first-child)'));
            
            // Separate directories and files
            const directories = entries.filter(tr => tr.classList.contains('directory-entry'));
            const files = entries.filter(tr => tr.classList.contains('file-entry'));
            
            // Sort directories
            directories.sort((a, b) => sortCompare(a, b));
            
            // Sort files
            files.sort((a, b) => sortCompare(a, b));
            
            // Clear table body
            while (tableBody.firstChild) {
              tableBody.removeChild(tableBody.firstChild);
            }
            
            // Re-add parent directory
            const parentRow = document.createElement('tr');
            parentRow.innerHTML = `
              <td>
                <div class="icon folder">📁</div>
                <a href="../">Parent Directory</a>
              </td>
              <td class="size">-</td>
              <td class="date hide-mobile">-</td>
            `;
            tableBody.appendChild(parentRow);
            
            // Add sorted directories
            directories.forEach(tr => tableBody.appendChild(tr));
            
            // Add sorted files
            files.forEach(tr => tableBody.appendChild(tr));
            
            // Update sort indicators
            updateSortIndicators();
          }
          
          // Comparison function for sorting
          function sortCompare(a, b) {
            const aValue = getSortValue(a);
            const bValue = getSortValue(b);
            
            // Directories always come before files
            if (a.dataset.type === 'dir' && b.dataset.type !== 'dir') return -1;
            if (a.dataset.type !== 'dir' && b.dataset.type === 'dir') return 1;
            
            // Compare based on sort column
            if (currentSort === 'size') {
              const aSize = parseInt(a.dataset.size || "0");
              const bSize = parseInt(b.dataset.size || "0");
              return currentOrder === 'ascending' ? aSize - bSize : bSize - aSize;
            }
            
            if (currentSort === 'mtime') {
              return currentOrder === 'ascending' 
                ? aValue.localeCompare(bValue) 
                : bValue.localeCompare(aValue);
            }
            
            // Default to name sorting
            return currentOrder === 'ascending' 
              ? aValue.localeCompare(bValue) 
              : bValue.localeCompare(aValue);
          }
          
          // Get sort value for a row
          function getSortValue(row) {
            if (currentSort === 'size') return row.dataset.size || "0";
            if (currentSort === 'mtime') return row.dataset.mtime || "";
            return row.dataset.name || "";
          }
          
          // Format file sizes
          function formatFileSizes() {
            const sizeCells = document.querySelectorAll('.size');
            sizeCells.forEach(cell => {
              const bytes = parseInt(cell.textContent);
              if (!isNaN(bytes)) {
                if (bytes === 0) cell.textContent = '0 B';
                else if (bytes < 1024) cell.textContent = bytes + ' B';
                else if (bytes < 1048576) cell.textContent = (bytes / 1024).toFixed(1) + ' KB';
                else if (bytes < 1073741824) cell.textContent = (bytes / 1048576).toFixed(1) + ' MB';
                else cell.textContent = (bytes / 1073741824).toFixed(1) + ' GB';
              }
            });
          }
          
          // Initialize on page load
          document.addEventListener('DOMContentLoaded', function() {
            initFromUrl();
            performSort();
            formatFileSizes();
          });
        ]]>
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>