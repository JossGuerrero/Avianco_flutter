import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/checkins_provider.dart';
import 'package:avianco/core/app_colors.dart';

class CheckinsScreen extends StatefulWidget {
  const CheckinsScreen({super.key});

  @override
  State<CheckinsScreen> createState() => _CheckinsScreenState();
}

class _CheckinsScreenState extends State<CheckinsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<CheckinsProvider>(context, listen: false).fetchCheckins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkinsData = Provider.of<CheckinsProvider>(context);
    final checkins = checkinsData.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          checkinsData.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              : checkins.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No hay registros de check-in.')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildCheckinCard(checkins[i]),
                          childCount: checkins.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Confirmación de Check-in',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.bannerGradient),
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.how_to_reg, size: 150, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckinCard(c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: AppColors.success,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reserva #${c.reservaId}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                          ),
                          _buildStatusBadge(c.estado),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.door_sliding_outlined, size: 16, color: AppColors.greyAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Puerta de embarque: ${c.puerta}',
                            style: const TextStyle(color: AppColors.greyAccent, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppColors.greyAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Fecha: ${c.fechaCheckin.toString().substring(0, 16)}',
                            style: const TextStyle(color: AppColors.greyAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
