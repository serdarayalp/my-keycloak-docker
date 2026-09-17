<#macro emailLayout>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
            "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>${realmName!''}</title>
        <style type="text/css">
            /* Client-spezifische Resets */
            body, table, td, a {
                -webkit-text-size-adjust: 100%;
                -ms-text-size-adjust: 100%;
            }

            table, td {
                mso-table-lspace: 0pt;
                mso-table-rspace: 0pt;
            }

            img {
                -ms-interpolation-mode: bicubic;
                border: 0;
                height: auto;
                line-height: 100%;
                outline: none;
                text-decoration: none;
            }

            /* Allgemeine Stile */
            body {
                height: 100% !important;
                margin: 0 !important;
                padding: 0 !important;
                width: 100% !important;
                background-color: #f4f6f8;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                color: #333333;
            }

            /* Responsive Design */
            @media screen and (max-width: 600px) {
                .email-container {
                    width: 100% !important;
                    padding: 10px !important;
                }

                .content-cell {
                    padding: 20px !important;
                }
            }
        </style>
    </head>
    <body style="margin: 0; padding: 0; background-color: #f4f6f8;">

    <!-- Haupt-Hintergrund-Tabelle -->
    <table border="0" cellpadding="0" cellspacing="0" width="100%"
           style="background-color: #f4f6f8; table-layout: fixed;">
        <tr>
            <td align="center" style="padding: 40px 0;">

                <!-- Zentrierter E-Mail-Container (Max. 600px Breite) -->
                <table border="0" cellpadding="0" cellspacing="0" width="600" class="email-container"
                       style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

                    <!-- 1. HEADER-BEREICH -->
                    <tr>
                        <td align="center" style="background-color: #0d6efd; padding: 30px 20px;">
                            <h1 style="color: #ffffff; font-size: 24px; font-weight: 700; margin: 0; text-transform: uppercase; letter-spacing: 1px;">

                            </h1>
                        </td>
                    </tr>

                    <!-- 2. INHALTS-BEREICH (Inhalts-Injection via FreeMarker) -->
                    <tr>
                        <td class="content-cell"
                            style="padding: 40px 30px; font-size: 16px; line-height: 1.6; color: #4a5568;">
                            <#nested>
                        </td>
                    </tr>

                    <!-- 3. FOOTER-BEREICH -->
                    <tr>
                        <td align="center"
                            style="background-color: #f8f9fa; padding: 20px; border-top: 1px solid #edf2f7; font-size: 13px; color: #a0aec0;">

                        </td>
                    </tr>

                </table>
                <!-- Ende E-Mail-Container -->

            </td>
        </tr>
    </table>

    </body>
    </html>
</#macro>