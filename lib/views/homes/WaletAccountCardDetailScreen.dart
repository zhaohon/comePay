import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/responses/crypto_response_model.dart';

class WaletAccountCardDetailScreen extends StatefulWidget {
  const WaletAccountCardDetailScreen({super.key});

  @override
  _WaletAccountCardDetailScreenState createState() =>
      _WaletAccountCardDetailScreenState();
}

class _WaletAccountCardDetailScreenState
    extends State<WaletAccountCardDetailScreen> {
  late CryptoResponse crypto;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CryptoResponse) {
      crypto = args;
    } else {
      // Default or error handling
      crypto = CryptoResponse(
        id: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        image: '',
        currentPrice: 0.0,
        priceChange24h: 0.0,
        priceChangePercentage24h: 0.0,
        sparklineIn7d: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCryptoColor(crypto.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              crypto.symbol.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // semua section rata kiri
          children: [
            // Balance & Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Balance\n0 ${crypto.symbol.toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Value\n\$${crypto.currentPrice.toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    //TODO
                    // color: Colors.black.withValues(alpha: 0.05 * 255),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "\$${crypto.currentPrice.toStringAsFixed(2)} ",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${crypto.priceChangePercentage24h >= 0 ? '+' : ''}${crypto.priceChangePercentage24h.toStringAsFixed(2)}%",
                        style: TextStyle(
                          color: crypto.priceChangePercentage24h >= 0
                              ? Colors.green
                              : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chart with fl_chart
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: crypto.sparklineIn7d
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: color,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              //TODO
                              // color: color.withValues(alpha: 0.1 * 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time filter buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text("1H", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("1D"),
                      Text("1W"),
                      Text("1M"),
                      Text("1Y"),
                      Text("All"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About ${crypto.name}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${crypto.name} is a cryptocurrency.",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Stats",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text("24h volume: -", style: TextStyle(color: Colors.black87)),
                Text("Market cap: -", style: TextStyle(color: Colors.black87)),
                Text("Total supply: -", style: TextStyle(color: Colors.black87)),
                Text("Circulating supply: -", style: TextStyle(color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons (CMC & CG)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLinkButton("CMC"),
                const SizedBox(width: 8),
                _buildLinkButton("CG"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCryptoColor(String id) {
    switch (id) {
      case 'bitcoin':
        return Colors.orange;
      case 'ethereum':
        return Colors.blue;
      case 'binancecoin':
        return Colors.yellow.shade700;
      case 'matic-network':
        return Colors.purple;
      case 'base':
        return Colors.blue.shade300;
      case 'tron':
        return Colors.red;
      case 'solana':
        return Colors.purple.shade300;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAction(IconData icon, String label) {
    return Container(
      height: 80,
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
