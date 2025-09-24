import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, of, forkJoin } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

export interface MaintenanceResponse {
  status: string;
  message: string;
  details: string;
  timestamp: string;
  service: string;
  supportContact: string;
  maintenanceValue: string;
}

export interface ServiceStatus {
  isInMaintenance: boolean;
  maintenanceDetails?: MaintenanceResponse;
  statusCode: number;
  message: string;
  serviceName: string;
  lastChecked: Date;
}

export interface AllServicesStatus {
  accounts: ServiceStatus;
  cards: ServiceStatus;
  loans: ServiceStatus;
  overallStatus: 'operational' | 'partial' | 'maintenance';
}

@Injectable({
  providedIn: 'root'
})
export class MaintenanceService {
  private readonly services = {
    accounts: { url: '/api/accounts/contact-info', port: 8080 },
    cards: { url: '/api/cards/contact-info', port: 9000 },
    loans: { url: '/api/loans/contact-info', port: 8090 }
  };

  constructor(private http: HttpClient) {}

  /**
   * Check all services status
   */
  checkAllServicesStatus(): Observable<AllServicesStatus> {
    const accountsCheck$ = this.checkSingleService('accounts', this.services.accounts.url);
    const cardsCheck$ = this.checkSingleService('cards', this.services.cards.url);
    const loansCheck$ = this.checkSingleService('loans', this.services.loans.url);

    return forkJoin({
      accounts: accountsCheck$,
      cards: cardsCheck$,
      loans: loansCheck$
    }).pipe(
      map(results => {
        const overallStatus = this.determineOverallStatus(results);
        return {
          ...results,
          overallStatus
        } as AllServicesStatus;
      })
    );
  }

  /**
   * Check individual service status
   */
  checkSingleService(serviceName: string, url: string): Observable<ServiceStatus> {
    return this.http.get<any>(url).pipe(
      map((_response: any) => {
        return {
          isInMaintenance: false,
          statusCode: 200,
          message: `${serviceName} service is available`,
          serviceName,
          lastChecked: new Date()
        } as ServiceStatus;
      }),
      catchError((error: HttpErrorResponse) => {
        return of(this.handleMaintenanceResponse(error, serviceName));
      })
    );
  }

  /**
   * Legacy method for backward compatibility
   */
  checkMaintenanceStatus(): Observable<ServiceStatus> {
    return this.checkSingleService('accounts', this.services.accounts.url);
  }

  private handleMaintenanceResponse(error: HttpErrorResponse, serviceName: string): ServiceStatus {
    console.log(`${serviceName} service response error:`, error);

    // Check if it's a 503 maintenance response
    if (error.status === 503) {
      try {
        const maintenanceData: MaintenanceResponse = error.error;

        if (maintenanceData && maintenanceData.status === 'SERVICE_UNAVAILABLE') {
          return {
            isInMaintenance: true,
            maintenanceDetails: maintenanceData,
            statusCode: 503,
            message: maintenanceData.message,
            serviceName,
            lastChecked: new Date()
          };
        }
      } catch (parseError) {
        console.error(`Failed to parse ${serviceName} maintenance response:`, parseError);
      }

      return {
        isInMaintenance: true,
        statusCode: 503,
        message: `${serviceName} service is currently under maintenance`,
        serviceName,
        lastChecked: new Date()
      };
    }

    // Handle connection errors (status 0)
    if (error.status === 0) {
      return {
        isInMaintenance: false,
        statusCode: 0,
        message: `Unable to connect to ${serviceName} service. Please check if the service is running on port ${this.getServicePort(serviceName)}.`,
        serviceName,
        lastChecked: new Date()
      };
    }

    // Handle other errors
    return {
      isInMaintenance: false,
      statusCode: error.status || 0,
      message: error.message || `Unable to reach ${serviceName} service`,
      serviceName,
      lastChecked: new Date()
    };
  }

  private determineOverallStatus(services: { accounts: ServiceStatus; cards: ServiceStatus; loans: ServiceStatus }): 'operational' | 'partial' | 'maintenance' {
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

  private getServicePort(serviceName: string): number {
    return this.services[serviceName as keyof typeof this.services]?.port || 8080;
  }

  /**
   * Parse maintenance timestamp for display
   */
  formatMaintenanceTimestamp(timestamp: string): string {
    try {
      return new Date(timestamp).toLocaleString();
    } catch {
      return '';
    }
  }

  /**
   * Get support contact from maintenance details
   */
  getSupportContact(maintenanceDetails?: MaintenanceResponse): string {
    return maintenanceDetails?.supportContact || 'support@eazybank.com';
  }
}
