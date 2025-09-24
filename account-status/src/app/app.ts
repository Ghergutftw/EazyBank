import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { interval, Subscription } from 'rxjs';
import { switchMap } from 'rxjs/operators';
import { MaintenanceService, MaintenanceResponse, ServiceStatus, AllServicesStatus } from './maintenance.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './app.html',
  styleUrls: ['./app.css']
})
export class App implements OnInit, OnDestroy {
  allServicesStatus: AllServicesStatus | undefined = undefined;
  statusMessage = 'Checking all services status...';
  lastCheckTime: Date | null = null;
  anyServiceInMaintenance = false;

  private checkSubscription?: Subscription;
  private currentInterval = 5000; // Start with 5 seconds
  private consecutiveFailures = 0;
  private readonly longInterval = 60000; // 1 minute

  constructor(private maintenanceService: MaintenanceService) {}

  ngOnInit() {
    this.checkAllServicesStatus();
    this.startStatusChecking();
  }

  ngOnDestroy() {
    if (this.checkSubscription) {
      this.checkSubscription.unsubscribe();
    }
  }

  private startStatusChecking() {
    this.checkSubscription = interval(this.currentInterval)
      .pipe(
        switchMap(() => this.maintenanceService.checkAllServicesStatus())
      )
      .subscribe(status => this.handleAllServicesStatus(status));
  }

  private checkAllServicesStatus() {
    this.statusMessage = 'Checking all services status...';
    this.maintenanceService.checkAllServicesStatus()
      .subscribe(status => this.handleAllServicesStatus(status));
  }

  private handleAllServicesStatus(status: AllServicesStatus) {
    this.lastCheckTime = new Date();
    this.allServicesStatus = status;

    // Determine if any service is in maintenance
    this.anyServiceInMaintenance = status.accounts.isInMaintenance ||
                                   status.cards.isInMaintenance ||
                                   status.loans.isInMaintenance;

    // Update status message based on overall status
    switch (status.overallStatus) {
      case 'operational':
        this.statusMessage = 'All services are operational';
        this.consecutiveFailures = 0;
        break;
      case 'partial':
        this.statusMessage = 'Some services are experiencing issues';
        this.consecutiveFailures++;
        break;
      case 'maintenance':
        this.statusMessage = 'All services are under maintenance';
        this.consecutiveFailures++;
        break;
    }

    // Switch to longer interval if there are issues
    if (this.consecutiveFailures >= 2 && this.currentInterval === 5000) {
      this.switchToLongInterval();
    } else if (status.overallStatus === 'operational' && this.currentInterval !== 5000) {
      this.switchToShortInterval();
    }
  }

  private switchToLongInterval() {
    if (this.currentInterval !== this.longInterval) {
      this.currentInterval = this.longInterval;
      this.restartInterval();
      this.statusMessage += ' - Checking every minute...';
    }
  }

  private switchToShortInterval() {
    if (this.currentInterval !== 5000) {
      this.currentInterval = 5000;
      this.consecutiveFailures = 0;
      this.restartInterval();
    }
  }

  private restartInterval() {
    if (this.checkSubscription) {
      this.checkSubscription.unsubscribe();
    }

    this.checkSubscription = interval(this.currentInterval)
      .pipe(
        switchMap(() => this.maintenanceService.checkAllServicesStatus())
      )
      .subscribe(status => this.handleAllServicesStatus(status));
  }

  checkNow() {
    this.switchToShortInterval();
    this.checkAllServicesStatus();
  }

  // Get service status by name
  getServiceStatus(serviceName: 'accounts' | 'cards' | 'loans'): ServiceStatus | undefined {
    return this.allServicesStatus?.[serviceName];
  }

  // Get formatted maintenance timestamp for a service
  getMaintenanceTimestamp(serviceName: 'accounts' | 'cards' | 'loans'): string {
    const service = this.getServiceStatus(serviceName);
    if (service?.maintenanceDetails?.timestamp) {
      return this.maintenanceService.formatMaintenanceTimestamp(service.maintenanceDetails.timestamp);
    }
    return '';
  }

  // Get support contact for a service
  getSupportContact(serviceName: 'accounts' | 'cards' | 'loans'): string {
    const service = this.getServiceStatus(serviceName);
    return this.maintenanceService.getSupportContact(service?.maintenanceDetails);
  }

  // Get status icon for a service
  getServiceStatusIcon(serviceName: 'accounts' | 'cards' | 'loans'): string {
    const service = this.getServiceStatus(serviceName);
    if (!service) return '❓';

    if (service.isInMaintenance) return '🔧';
    if (service.statusCode === 0) return '🔴';
    if (service.statusCode === 200) return '🟢';
    return '🟡';
  }

  // Get status class for styling
  getServiceStatusClass(serviceName: 'accounts' | 'cards' | 'loans'): string {
    const service = this.getServiceStatus(serviceName);
    if (!service) return 'unknown';

    if (service.isInMaintenance) return 'maintenance';
    if (service.statusCode === 0) return 'offline';
    if (service.statusCode === 200) return 'online';
    return 'warning';
  }

  // Test individual service
  testService(serviceName: 'accounts' | 'cards' | 'loans') {
    const serviceUrl = serviceName === 'accounts' ? '/api/accounts/contact-info' :
                      serviceName === 'cards' ? '/api/cards/contact-info' :
                      '/api/loans/contact-info';

    this.statusMessage = `Testing ${serviceName} service...`;
    this.maintenanceService.checkSingleService(serviceName, serviceUrl)
      .subscribe(status => {
        // Update just this service in the overall status
        if (this.allServicesStatus) {
          // Create a new status object to avoid reference issues
          const updatedStatus = {
            ...this.allServicesStatus,
            [serviceName]: status
          };

          // Recalculate overall status properly
          const overallStatus = this.calculateOverallStatus(updatedStatus);
          this.allServicesStatus = {
            ...updatedStatus,
            overallStatus
          };

          // Update the display without triggering interval changes
          this.updateDisplayStatus();
        }
      });
  }

  // Calculate overall status without side effects
  calculateOverallStatus(services: AllServicesStatus): 'operational' | 'partial' | 'maintenance' {
    const statuses = [services.accounts, services.cards, services.loans];
    const maintenanceCount = statuses.filter(s => s.isInMaintenance).length;
    const unavailableCount = statuses.filter(s => s.statusCode === 0).length;

    if (maintenanceCount === 3 || unavailableCount === 3) {
      return 'maintenance';
    } else if (maintenanceCount > 0 || unavailableCount > 0) {
      return 'partial';
    } else {
      return 'operational';
    }
  }

  // Update display status without affecting intervals
  updateDisplayStatus() {
    if (!this.allServicesStatus) return;

    this.lastCheckTime = new Date();

    // Determine if any service is in maintenance
    this.anyServiceInMaintenance = this.allServicesStatus.accounts.isInMaintenance ||
                                   this.allServicesStatus.cards.isInMaintenance ||
                                   this.allServicesStatus.loans.isInMaintenance;

    // Update status message based on overall status without affecting intervals
    switch (this.allServicesStatus.overallStatus) {
      case 'operational':
        this.statusMessage = 'All services are operational';
        break;
      case 'partial':
        this.statusMessage = 'Some services are experiencing issues';
        break;
      case 'maintenance':
        this.statusMessage = 'All services are under maintenance';
        break;
    }
  }
}
